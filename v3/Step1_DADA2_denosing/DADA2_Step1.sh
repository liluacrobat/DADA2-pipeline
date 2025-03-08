#!/bin/bash -l
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=70000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="DADA2-pipeline"
#SBATCH --mail-user=lli59@buffalo.edu
#SBATCH --output=DADA2-pipeline-Step1.log
#SBATCH --mail-type=ALL

export CCR_BUILD_PREFIX=/projects/academic/pidiazmo/projectsoftwares/easybuild
export CCR_CUSTOM_BUILD_PATHS=$CCR_BUILD_PREFIX
module load qiime2/2022.11

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path pe-32-manifest \
  --output-path demux-paired-end.qza \
  --input-format PairedEndFastqManifestPhred33V2

qiime demux summarize \
--i-data demux-paired-end.qza \
--o-visualization demux-paired-end.qzv

qiime dada2 denoise-paired \
--i-demultiplexed-seqs demux-paired-end.qza \
--p-trim-left-f 1 \
--p-trim-left-r 1 \
--p-trunc-len-f 260 \
--p-trunc-len-r 240 \
--p-min-fold-parent-over-abundance 1.9  \
--p-n-threads 12 \
--o-table table3.qza \
--o-representative-sequences rep-seqs.qza \
--o-denoising-stats denoising-stats.qza \
--verbose

qiime metadata tabulate \
  --m-input-file denoising-stats.qza \
  --o-visualization denoising-stats.qzv
  

  
