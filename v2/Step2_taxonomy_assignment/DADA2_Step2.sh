#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=70000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="DADA2-S2"
#SBATCH --mail-user=lli59@buffalo.edu
#SBATCH --output=DADA2-pipeline-Step2.log
#SBATCH --mail-type=ALL

./16s_analysis_pipeline.sh -d data2_output
