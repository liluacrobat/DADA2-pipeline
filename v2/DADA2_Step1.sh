#!/bin/sh
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

module load qiime2
conda activate /projects/academic/pidiazmo/projectsoftwares/env/qiime2-2020.8

export LD_LIBRARY_PATH=/projects/academic/pidiazmo/projectsoftwares/env/qiime2-2020.8/lib/python3.6/site-packages/matplotlib/../../../libstdc++.so.6:$LD_LIBRARY_PATH

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path pe-32-manifest \
  --output-path paired-end-demux.qza \
  --input-format PairedEndFastqManifestPhred33V2

qiime demux summarize \
--i-data demux-paired-end.qza \
--o-visualization demux-paired-end.qzv

qiime dada2 denoise-paired \
--i-demultiplexed-seqs demux-paired-end.qza \
--p-trim-left-f 7 \
--p-trim-left-r 10 \
--p-max-ee-f 5 \
--p-max-ee-r 5 \
--p-trunc-len-f 300 \
--p-trunc-len-r 240 \
--p-n-threads 12 \
--o-table table1.qza \
--o-representative-sequences rep-seqs1.qza \
--o-denoising-stats denoising-stats1.qza \
--verbose

qiime dada2 denoise-paired \
--i-demultiplexed-seqs demux-paired-end.qza \
--p-trim-left-f 7 \
--p-trim-left-r 10 \
--p-trunc-len-f 260 \
--p-trunc-len-r 240 \
--p-max-ee-f 5 \
--p-max-ee-r 5 \
--p-n-threads 12 \
--o-table table4.qza \
--o-representative-sequences rep-seqs4.qza \
--o-denoising-stats denoising-stats4.qza \
--verbose

qiime metadata tabulate \
  --m-input-file denoising-stats1.qza \
  --o-visualization denoising-stats1.qzv
  
qiime metadata tabulate \
  --m-input-file denoising-stats4.qza \
  --o-visualization denoising-stats4.qzv
  
