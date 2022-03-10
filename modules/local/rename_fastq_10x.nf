
process RENAME_FASTQ_10X {
    tag "$meta.run_accession"
    label 'error_retry'

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
    def seq_run = meta.seq_run ?: 1 //numeric identifier for samples resequenced on separate flowcells

    fastq_output = '*.fastq.gz'
    
    """
    rename_fastq_10x.py \\
        --dir ./ \\
        --sample_id $meta.sample_id \\
        --seq_run $seq_run \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
