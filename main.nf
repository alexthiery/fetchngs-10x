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

/*
========================================================================================
    VALIDATE & PRINT PARAMETER SUMMARY
========================================================================================
*/


// Check if --input file is empty
// ch_input = file(params.input, checkIfExists: true)
// if (ch_input.isEmpty()) {exit 1, "File provided with --input is empty: ${ch_input.getName()}!"}

// Read in ids from --input file
Channel
    .from(file(params.input, checkIfExists: true))
    .splitCsv(header:true, sep:'', strip:true)
    // .map{meta -> [meta, meta.id]}
    .map{it.id}
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

    // //
    // // Convert the SRA format into one or more compressed FASTQ files.
    // //
    // SRATOOLS_FASTQDUMP ( SRATOOLS_PREFETCH.out )
    // ch_versions = ch_versions.mix( SRATOOLS_FASTQDUMP.out.versions.first() )

}

/*
========================================================================================
    THE END
========================================================================================
*/