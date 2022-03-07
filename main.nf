#!/usr/bin/env nextflow
/*
========================================================================================
    luslab/scmultiomic
========================================================================================
*/

nextflow.enable.dsl = 2

/*
========================================================================================
    GENOME PARAMETER VALUES
========================================================================================
*/

// if (!params.fasta) {
//     params.chromap_index   = WorkflowMain.getGenomeAttribute(params, 'chromap')
// } else {
//     params.chromap_index   = null
// }

params.fasta     = WorkflowMain.getGenomeAttribute(params, 'fasta')
params.gtf       = WorkflowMain.getGenomeAttribute(params, 'gtf')
// params.gene_bed  = WorkflowMain.getGenomeAttribute(params, 'bed12')
// params.blacklist = WorkflowMain.getGenomeAttribute(params, 'blacklist')

/*
========================================================================================
    VALIDATE & PRINT PARAMETER SUMMARY
========================================================================================
*/

// WorkflowMain.initialise(workflow, params, log)

/*
========================================================================================
    NAMED WORKFLOW FOR PIPELINE
========================================================================================
*/

// include { CUSTOMSC } from './workflows/custom_sc'

// workflow LUSLAB_CUSTOMSC {
//     CUSTOMSC ()
// }

include { CELLRANGER_MULTIOMIC } from './workflows/cellranger_multiomic'

workflow LUSLAB_CELLRANGER_MULTIOMIC {
    CELLRANGER_MULTIOMIC ()
}

/*
========================================================================================
    RUN ALL WORKFLOWS
========================================================================================
*/

// workflow {
//     LUSLAB_CUSTOMSC ()
// }

workflow {
    LUSLAB_CELLRANGER_MULTIOMIC ()
}


/*
========================================================================================
    THE END
========================================================================================
*/
