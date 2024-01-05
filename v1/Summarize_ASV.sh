#!/bin/sh

module load R/3.1.2
module load qiime/1.9.1

biom convert -i final_feature_table_ASV.txt -o final_feature_table_ASV.biom --to-json --table-type "OTU table" --process-obs-metadata taxonomy

summarize_taxa.py -i final_feature_table_ASV.biom -o tax_mapping_counts/ -L 2,3,4,5,6,7 -a
summarize_taxa.py -i final_feature_table_ASV.biom -o tax_mapping_rel/ -L 2,3,4,5,6,7
