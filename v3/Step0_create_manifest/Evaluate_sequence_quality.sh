#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=30000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="S0"
#SBATCH --mail-user=lli59@buffalo.edu
#SBATCH --output=S0.log
#SBATCH --mail-type=ALL

cd fastq
for x in $(ls *.gz); do gunzip $x;done

eval "$(/util/common/python/py38/anaconda-2020.07/bin/conda shell.bash hook)"
conda activate /projects/academic/pidiazmo/projectsoftwares/minion
mkdir fastqc
fastqc -o fastqc *.fastq
cd fastqc
multiqc . --interactive
cd ..

mkdir LS.txt
