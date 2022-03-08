#!/bin/sh
#SBATCH --job-name=Integrated-npb/NF-fetchngs
#SBATCH -t 72:00:00
#SBATCH --mail-type=ALL,ARRAY_TASKS
#SBATCH --mail-user=alex.thiery@crick.ac.uk

## LOAD REQUIRED MODULES
ml purge
ml Nextflow/21.10.6
ml Singularity/3.6.4
ml Graphviz

export TERM=xterm
export NXF_VER=21.10.6
export NXF_SINGULARITY_CACHEDIR=/camp/home/thierya/working/NF_singularity

nextflow run main.nf \
    -profile crick \
    --input ./tests/test.txtt \
    --outdir ./output/NF-fetchngs \
    --email alex.thiery@crick.ac.uk \
    -resume