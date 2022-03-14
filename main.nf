#!/usr/bin/env nextflow
/*

nextflow.enable.dsl = 2

/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
========================================================================================
*/

include { SRA_IDS_TO_RUNINFO      } from './modules/local/sra_ids_to_runinfo'
include { SRA_MERGE_SAMPLESHEET   } from './modules/local/sra_merge_samplesheet'
include { SRATOOLS_PREFETCH    } from './modules/local/sratools_prefetch'
include { SRATOOLS_FASTQDUMP } from './modules/local/sratools_fastqdump'
include { RENAME_FASTQ_10X } from './modules/local/rename_fastq_10x'

/*
========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
========================================================================================
*/

include { CUSTOM_DUMPSOFTWAREVERSIONS } from './modules/nf-core/modules/custom/dumpsoftwareversions/main'

/*
========================================================================================
    VALIDATE & PRINT PARAMETER SUMMARY
========================================================================================
*/


// Check if --input file is empty
ch_input = file(params.input, checkIfExists: true)
if (ch_input.isEmpty()) {exit 1, "File provided with --input is empty: ${ch_input.getName()}!"}

// Read in ids from --input file
Channel
    .from(file(params.input, checkIfExists: true))
    .splitCsv(header:true, sep:'', strip:true)
    .map{it.sra_id}
    .set { ch_ids }


/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow {

    ch_versions = Channel.empty()

    // //
    // // MODULE: Get SRA run information for public database ids
    // //
    SRA_IDS_TO_RUNINFO (
        ch_ids,
        params.ena_metadata_fields ?: ''
    )
    ch_versions = ch_versions.mix(SRA_IDS_TO_RUNINFO.out.versions.first())

    //
    // MODULE: Create a merged samplesheet across all samples for the pipeline
    //
    // SRA_IDS_TO_RUNINFO.out.tsv.collect.view()
    SRA_MERGE_SAMPLESHEET (
        SRA_IDS_TO_RUNINFO.out.tsv.collect()
    )
    ch_versions = ch_versions.mix(SRA_MERGE_SAMPLESHEET.out.versions)

    SRA_MERGE_SAMPLESHEET
        .out
        .samplesheet
        .splitCsv(header:true, sep:'\t')
        .map { meta -> [meta, meta.run_accession]}
        .set { ch_sra_reads }

    //
    // Prefetch sequencing reads in SRA format.
    //
    SRATOOLS_PREFETCH ( ch_sra_reads )
    ch_versions = ch_versions.mix( SRATOOLS_PREFETCH.out.versions.first() )

    //
    // Convert the SRA format into one or more compressed FASTQ files.
    //
    SRATOOLS_FASTQDUMP ( SRATOOLS_PREFETCH.out.sra )
    ch_versions = ch_versions.mix( SRATOOLS_FASTQDUMP.out.versions.first() )


    SRATOOLS_FASTQDUMP
        .out
        .reads
        .map{row -> [[
            experiment_accession: row[0].experiment_accession,
            sample_title: row[0].sample_title
            ],
            row[1]
            ]}
        .view()
        .groupTuple(by: 0)
        // .map{row -> [row[1], row[2]]}
        .set{ ch_fastqs }

    //
    // Convert the fastq file names to 10x format.
    //
    if (params.rename_fastq){
        RENAME_FASTQ_10X ( ch_fastqs )
        ch_versions = ch_versions.mix( RENAME_FASTQ_10X.out.versions.first() )
    }

    //
    // MODULE: Dump software versions for all tools used in the workflow
    //
    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )
}

/*
========================================================================================
    THE END
========================================================================================
*/