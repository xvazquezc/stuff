#!/usr/bin/env bash

# This script parses the output from IPRS with the -goterms option so it can be imported into anvio with anvi-import-functions

INPUT=${1?I need a file to work...}
OUTPUT=${2:-iprs_go_matrix.tsv}

cut -f 1,9,14 ${INPUT} | grep "GO:" |\
while read -r f1 f2 c1
do
for c in ${c1//|/ }
	do
	printf "$f1 $f2 $c\n"
done
done |\
awk 'BEGIN {print "gene_callers_id\tsource\taccession\tfunction\te_value"} {print $1"\tGO\t"$3"\t\t"$2}' > ${OUTPUT%}
