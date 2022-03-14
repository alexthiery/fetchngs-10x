
process RENAME_FASTQ_10X {
    tag "$meta.experiment_accession"
    label 'error_retry'
    label 'process_low'

    conda (params.enable_conda ? "conda-forge::python=3.9.5" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'quay.io/biocontainers/python:3.9--1' }"

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path(fastq_output), emit: reads
    path "versions.yml"                , emit: versions

    script:
    def args = task.ext.args  ?: ''
    fastq_output = '*.fastq.gz'
    
    """
    rename_fastq_10x.py \\
        --dir ./ \\
        --sample_id $meta.experiment_accession \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
