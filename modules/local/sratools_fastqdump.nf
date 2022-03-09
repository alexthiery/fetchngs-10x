
process SRATOOLS_FASTQDUMP {
    tag "$sra"
    label 'process_medium'

    conda (params.enable_conda ? 'bioconda::sra-tools=2.11.0 conda-forge::pigz=2.6' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-5f89fe0cd045cb1d615630b9261a1d17943a9b6a:6a9ff0e76ec016c3d0d27e0c0d362339f2d787e6-0' :
        'quay.io/biocontainers/mulled-v2-5f89fe0cd045cb1d615630b9261a1d17943a9b6a:6a9ff0e76ec016c3d0d27e0c0d362339f2d787e6-0' }"

    input:
    tuple val(meta), path(sra)

    output:
    tuple val(meta), path(fastq_output), emit: reads
    path "versions.yml"                , emit: versions

    script:
    def args = task.ext.args  ?: ''

    """
    fastq-dump \\
        $args \\
        ${sra.name}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sratools: \$(fastq-dump --version 2>&1 | grep -Eo '[0-9.]+')
    END_VERSIONS
    """
}
