#!/bin/sh
#SBATCH --partition=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=30000
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="DADA2-pipeline"
#SBATCH --mail-user=lli59@buffalo.edu
#SBATCH --output=DADA2-pipeline-Step1.log
#SBATCH --mail-type=ALL

module load qiime2
conda activate /projects/academic/pidiazmo/projectsoftwares/env/qiime2-2020.8

qiime tools import \
--type 'SampleData[PairedEndSequencesWithQuality]' \
--input-path ./fastq \
--input-format CasavaOneEightSingleLanePerSampleDirFmt \
--output-path ./demux-paired-end.qza

qiime demux summarize \
--i-data demux-paired-end.qza \
--o-visualization demux-paired-end.qzv


qiime dada2 denoise-paired \
--i-demultiplexed-seqs demux-paired-end.qza \
--p-trim-left-f 17 \
--p-trim-left-r 6 \
--p-max-ee-f 5 \
--p-max-ee-r 5 \
--p-trunc-len-f 301 \
--p-trunc-len-r 240 \
--p-n-threads 12 \
--o-table table1.qza \
--o-representative-sequences rep-seqs1.qza \
--o-denoising-stats denoising-stats1.qza \
--verbose

qiime dada2 denoise-paired \
--i-demultiplexed-seqs demux-paired-end.qza \
--p-trim-left-f 17 \
--p-trim-left-r 6 \
--p-trunc-len-f 301 \
--p-trunc-len-r 240 \
--p-n-threads 12 \
--o-table table2.qza \
--o-representative-sequences rep-seqs2.qza \
--o-denoising-stats denoising-stats2.qza \
--verbose

qiime dada2 denoise-paired \
--i-demultiplexed-seqs demux-paired-end.qza \
--p-trim-left-f 17 \
--p-trim-left-r 6 \
--p-trunc-len-f 260 \
--p-trunc-len-r 240 \
--p-n-threads 12 \
--o-table table3.qza \
--o-representative-sequences rep-seqs3.qza \
--o-denoising-stats denoising-stats3.qza \
--verbose

qiime dada2 denoise-paired \
--i-demultiplexed-seqs demux-paired-end.qza \
--p-trim-left-f 17 \
--p-trim-left-r 6 \
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
  --m-input-file denoising-stats2.qza \
  --o-visualization denoising-stats2.qzv
  
qiime metadata tabulate \
  --m-input-file denoising-stats3.qza \
  --o-visualization denoising-stats3.qzv
  
qiime metadata tabulate \
  --m-input-file denoising-stats4.qza \
  --o-visualization denoising-stats4.qzv
  
