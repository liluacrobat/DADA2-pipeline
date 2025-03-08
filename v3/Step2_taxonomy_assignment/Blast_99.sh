#!/bin/sh
set -e

module load gcc/11.2.0  openmpi/4.1.1
module load blast+/2.12.0

echo '--------------------'
echo 'preprocessing...'
START=`date +%s`


makeblastdb -in /projects/academic/pidiazmo/16S_Database/HOMD/eHOMD15.2/HOMD_16S_rRNA_RefSeq_V15.22.fasta -out HOMD -dbtype 'nucl' -input_type fasta

blastn -query ./dna-sequences.fasta -task megablast -db HOMD  -perc_identity 99 -qcov_hsp_perc 90 -max_target_seqs 5000 -outfmt "7 qacc sacc qstart qend sstart send length pident qcovhsp qcovs" -out blast_99_taxonomy

END=`date +%s`
ELAPSED=$(( $END - $START ))
echo "preprocessing takes "$ELAPSED " s"
