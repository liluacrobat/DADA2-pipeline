#!/bin/bash -l
#SBATCH --partition=general-compute
#SBATCH --qos=general-compute
#SBATCH --time=71:00:00
#SBATCH --nodes=1
#SBATCH --mem=70G
#SBATCH --ntasks-per-node=12
#SBATCH --job-name="DADA2-S2"
#SBATCH --mail-user=lli59@buffalo.edu
#SBATCH --output=DADA2-pipeline-Step2.log
#SBATCH --mail-type=ALL

echo '-------------------------------------------------------------------------'
echo 'STEP 1: Loading environment...'
echo '-------------------------------------------------------------------------'
export CCR_BUILD_PREFIX=/projects/academic/pidiazmo/projectsoftwares/easybuild
export CCR_CUSTOM_BUILD_PATHS=$CCR_BUILD_PREFIX
module load qiime2/2022.11

REF_FA='/projects/academic/pidiazmo/16S_Database/HOMD/eHOMD15.23/HOMD_16S_rRNA_RefSeq_V15.23.p9.fasta'
REF_TAX='/projects/academic/pidiazmo/16S_Database/HOMD/eHOMD15.23/HOMD_16S_rRNA_RefSeq_V15.23.mothur.taxonomy'

echo '-------------------------------------------------------------------------'
echo 'STEP 2: Exporting DADA2 output'
echo '-------------------------------------------------------------------------'

qiime tools export \
    --input-path ./rep-seqs.qza \
    --output-path ./rep-seqs
    
qiime tools export \
    --input-path ./table.qza \
    --output-path ./table

echo '-------------------------------------------------------------------------'
echo 'STEP 3: Generating count table...'
echo '-------------------------------------------------------------------------'
module load gcc/11.2.0  openmpi/4.1.1
module load biom-format/2.1.12

biom convert -i ./table/feature-table.biom -o ./table/feature-table.txt --to-tsv
sed '1d' ./table/feature-table.txt > ./table/feature-table-no-head.txt

echo '-------------------------------------------------------------------------'
echo 'STEP 4: Creating link for feature-table and rep-sequences...'
echo '-------------------------------------------------------------------------'
ln -s ./table/feature-table-no-head.txt ./feature-table-no-head.txt
ln -s ./rep-seqs/dna-sequences.fasta ./dna-sequences.fasta

echo '-------------------------------------------------------------------------'
echo 'STEP 5: Assigning blast taxonomy...'
echo '-------------------------------------------------------------------------'
module load gcc/11.2.0  openmpi/4.1.1
module load blast+/2.12.0
makeblastdb -in $REF_FA -out blastDB4run -dbtype 'nucl' -input_type fasta
blastn -query ./dna-sequences.fasta -task megablast -db blastDB4run  -perc_identity 99 -qcov_hsp_perc 90 -max_target_seqs 5000 -outfmt "7 qacc sacc qstart qend sstart send length pident qcovhsp qcovs" -out blast_99_taxonomy


module load scipy-bundle/2021.10
python blast_parse.py -i ./blast_99_taxonomy -o ./parsed_blast_taxonomy_99
python make_taxonomy_table.py -b ./parsed_blast_taxonomy_99 -t $REF_TAX -u ./final_blast_taxonomy_99

echo '-------------------------------------------------------------------------'
echo 'STEP 6: Converting blast taxonomy file...'
echo '-------------------------------------------------------------------------'
python blast_parse.py -i ./blast_99_taxonomy -o ./parsed_blast_taxonomy_99

echo '-------------------------------------------------------------------------'
echo 'STEP 7: Mapping taxonomy name to identity colum in blast taxonomy file...'
echo '-------------------------------------------------------------------------'
python make_taxonomy_table.py -b ./parsed_blast_taxonomy_99 -t $REF_TAX -u ./final_blast_taxonomy_99

echo '-------------------------------------------------------------------------'
echo 'STEP 8: Loading Mothur environment...'
echo '-------------------------------------------------------------------------'
MOTHURPATH='/projects/academic/pidiazmo/projectsoftwares/mothur/v1.48.1'

echo '-------------------------------------------------------------------------'
echo 'STEP 9: Assiging rdp taxonomy...'
echo '-------------------------------------------------------------------------'
$MOTHURPATH/mothur "#classify.seqs(fasta=./dna-sequences.fasta, reference="$REF_FA", taxonomy="$REF_TAX")"


echo '-------------------------------------------------------------------------'
echo 'STEP 10: Removing rdp prefix and suffixes...'
echo '-------------------------------------------------------------------------'
python remove_rdp_prefix.py -t dna-sequences.mothur.wang.taxonomy

echo '-------------------------------------------------------------------------'
echo 'STEP 11: Merging blast and rdp results'
echo '-------------------------------------------------------------------------'
python merge_blast_rdp.py -b final_blast_taxonomy_99 -r transformed_rdp_taxonomy.txt -o merged_taxonomy_99.txt

echo '-------------------------------------------------------------------------'
echo 'STEP 12: Getting final feature table with taxonomy...'
echo '-------------------------------------------------------------------------'
python merge_taxonomy_table.py -t ./feature-table-no-head.txt merged_taxonomy_99.txt -o final_feature_table_99.txt
