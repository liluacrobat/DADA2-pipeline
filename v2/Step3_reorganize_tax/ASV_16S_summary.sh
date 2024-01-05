#!/bin/sh
#module load qiime2
conda activate qiime
biom convert -i ASV_table_99.reformated.txt -o ASV_table_99.reformated.biom --to-json --table-type "OTU table" --process-obs-metadata taxonomy

summarize_taxa.py -i ASV_table_99.reformated.biom -o tax_mapping_counts/ -L 2,3,4,5,6,7 -a
summarize_taxa.py -i ASV_table_99.reformated.biom -o tax_mapping_rel/ -L 2,3,4,5,6,7


