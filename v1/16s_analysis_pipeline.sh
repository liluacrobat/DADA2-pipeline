#!/bin/sh

while getopts d: flag
do
	case "${flag}" in 
		d) dada2_direc=${OPTARG};;
	esac
done

if [ -z "$dada2_direc" ];
then
	echo 'No directory path provided for dada2 output files. Please see the usage: '
	echo 'Usage: ./16s_analysis_pipeline -d <directory_path>'
	exit
fi

echo 'directory: ' $dada2_direc

REF_DB_DIREC="/projects/academic/pidiazmo/16S_Database/HOMD/eHOMD15.2"

START=`date +%s`

echo '-------------------------------------------------------------------------'
echo 'STEP 1: Loading environment...'
echo '-------------------------------------------------------------------------'
module load qiime2
conda activate /projects/academic/pidiazmo/projectsoftwares/env/qiime2-2020.8

if [ $? -eq 0 ];
then
	echo '-------------------------------------------------------------------------'
	echo 'STEP 2: Exporting DADA2 output'
	echo '-------------------------------------------------------------------------'
	qiime tools export \
	--input-path ./$dada2_direc/rep-seqs.qza \
	--output-path ./rep-seqs
	
	qiime tools export \
	--input-path ./$dada2_direc/table.qza \
	--output-path ./table
else
	exit
fi

if [ $? -eq 0 ];
then
	echo '-------------------------------------------------------------------------'
	echo 'STEP 3: Loading Mothur environment...'
	echo '-------------------------------------------------------------------------'
	module use /projects/academic/pidiazmo/projectmodules
	module load mothur/1.44.3
fi

echo '-------------------------------------------------------------------------'
echo 'STEP 4: Generating count table...'
echo '-------------------------------------------------------------------------'
if [ $? -eq 0 ];
then
	biom convert -i ./table/feature-table.biom -o ./table/feature-table.txt --to-tsv
    sed '1d' ./table/feature-table.txt > ./table/feature-table-no-head.txt
fi

if [ $? == 0 ];
then
	echo '-------------------------------------------------------------------------'
	echo 'STEP 5: Creating link for feature-table and rep-sequences...'
	echo '-------------------------------------------------------------------------'
	ln -s ./table/feature-table.userLabel.userLabel.count_table ./feature-table.userLabel.userLabel.count_table
	ln -s ./rep-seqs/dna-sequences.fasta ./dna-sequences.fasta
fi

echo '-------------------------------------------------------------------------'
echo 'STEP 6: Assigning blast taxonomy...'
echo '-------------------------------------------------------------------------'
./Blast_99.sh

echo '-------------------------------------------------------------------------'
echo 'STEP 7: Converting blast taxonomy file...'
echo '-------------------------------------------------------------------------'
python blast_parse.py -i ./blast_99_taxonomy -o ./parsed_blast_taxonomy_99

echo '-------------------------------------------------------------------------'
echo 'STEP 8: Mapping taxonomy name to identity colum in blast taxonomy file...'
echo '-------------------------------------------------------------------------'
python make_taxonomy_table.py -b ./parsed_blast_taxonomy_99 -t $REF_DB_DIREC/HOMD_16S_rRNA_RefSeq_V15.22.mothur.taxonomy -u ./final_blast_taxonomy_99

echo '-------------------------------------------------------------------------'
echo 'STEP 9: Assiging rdp taxonomy...'
echo '-------------------------------------------------------------------------'
mothur "#classify.seqs(fasta=./dna-sequences.fasta, reference="$REF_DB_DIREC"/HOMD_16S_rRNA_RefSeq_V15.22.fasta, taxonomy="$REF_DB_DIREC"/HOMD_16S_rRNA_RefSeq_V15.22.mothur.taxonomy)"

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
python merge_taxonomy_table.py -t ./table/feature-table-no-head.txt merged_taxonomy_99.txt -o final_feature_table_99.txt

echo '-------------------------------------------------------------------------'
echo 'STEP 7: Converting blast taxonomy file...'
echo '-------------------------------------------------------------------------'
python blast_parse.py -i ./blast_97_taxonomy -o ./parsed_blast_taxonomy_97

echo '-------------------------------------------------------------------------'
echo 'STEP 8: Mapping taxonomy name to identity colum in blast taxonomy file...'
echo '-------------------------------------------------------------------------'
python make_taxonomy_table.py -b ./parsed_blast_taxonomy_97 -t $REF_DB_DIREC/HOMD_16S_rRNA_RefSeq_V15.22.mothur.taxonomy -u ./final_blast_taxonomy_97

echo '-------------------------------------------------------------------------'
echo 'STEP 11: Merging blast and rdp results'
echo '-------------------------------------------------------------------------'
python merge_blast_rdp.py -b final_blast_taxonomy_97 -r transformed_rdp_taxonomy.txt -o merged_taxonomy_97.txt

echo '-------------------------------------------------------------------------'
echo 'STEP 12: Getting final feature table with taxonomy...'
echo '-------------------------------------------------------------------------'
python merge_taxonomy_table.py -t ./table/feature-table-no-head.txt merged_taxonomy_97.txt -o final_feature_table_97.txt

END=`date +%s`
ELAPSED=$(( $END - $START ))

echo 'It took: '$ELAPSED' s'
