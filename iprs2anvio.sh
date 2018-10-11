#!/usr/bin/env bash

# Author:       Xabier Vázquez-Campos
# Email:        xvazquezc@gmail.com
# Date:         2018-10-11
# License:      GNU General Public License
# Usage:        iprs2anvio.sh -i iprs_output.tsv -o input4anvio_prefix [-d|--db db_list] [-g|--go_terms] [-p|--pathways] [-r|--ipr] [-s|--split] [-h|--help]
# Description:  Script to parse InterProScan annotations into table format suitable for importing into Anvi'o.

VERSION=0.2.0

cmd(){
  echo `basename $0`;
}

usage(){
  echo "\

  `cmd` v${VERSION}
  "
  echo "\
  USAGE
  `cmd` -i iprs_output.tsv -o output_prefix
  [-d|--db db_list] [-g|--go_terms] [-p|--pathways] [-r|--ipr] [-s|--split] [-h|--help]"
  echo "\
  ;
  REQUIRED
  -i, --input; Output file from InterProScan in tsv format.
  -o, --output; Prefix for the output file(s).
  ;
  OPTIONAL
  -d, --db; Only extract the annotations of specific databases. All annotations
              ; will be extracted by default. For multiple databases, use a
              ; comma-separated list.
  -g, --go_terms; Extract GO terms.
  -p, --pathways; Extract pathway annotations.
  -r, --ipr; Extract InterPro cross-reference annotations.
  -s, --split; Annotations from each database will be written in individual files.
  ;
  MISCELLANEOUS
  -h, --help; Show this help information and exits.
  " | column -t -s ";"
}


BASENAME=$(cmd)

OPTIONS=i:,o:,d:,g,p,h,r,s
LONGOPTIONS=input:,output:,db:,go_terms,pathways,help,ipr,split

# -temporarily store output to be able to check for errors
# -e.g. use “--options” parameter by name to activate quoting/enhanced mode
# -pass arguments only via   -- "$@"   to separate them correctly
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")

if [[ $? -ne 0 ]]; then
    # e.g. $? == 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

# handle non-option arguments
if [[ $# -eq 1 ]]; then
    usage
    exit 4
fi


# now enjoy the options in order and nicely split until we see --
while true; do
   case "$1" in
     -i|--input)
        INPUT=${2}
        shift 2;;
     -o|--output)
        OUTPUT=${2}
        shift 2;;
     -d|--db) ## if only one just
          if [[ $2 =~ "," ]]; then
            DATABASES=($( echo $2 | tr "," " " ))
          else DATABASES=($2)
          fi
          shift 2;;
     -g|--go_terms)
          GOTERMS=true
          shift;;
     -p|--pathways)
          PATHWAYS=true
          shift;;
     -r|--ipr)
          IPR=true
          shift;;
     -s|--split)
          SPLIT=true
          shift;;
     -h|--help)
          usage
          exit;;
     --)
          shift
          break;;
     # -*|--*)
     #     echo "\"$1\" is not a valid flag.\
     #     Try with '`cmd` --help' for more information."
     #     exit 1;;
     *)
         if [ -z "$1" ]; then break; else echo "'$1' is not a valid option"; exit 3; fi;;
   esac
done

if [[ $# -ne 0 ]]; then
   echo $@ invalid option
   exit 4
fi


extract_dbs(){
  cat ${1} | awk -F '\t' -v db=${3} 'match($4, db)' | awk -F '\t' '{print $1 "\t" $4 "\t" $5 "\t" $6 "\t" $9}'| sort -h | uniq > ${PREFIX}.${2}_${3}.tmp
}

extract_go(){
  cat ${1} | awk -F '\t' '{OFS="\t" ; $14 ~ "GO:"}; {print $1 "\t" $9 "\t" $14}' |\
  while read -r f1 f2 c1
  do
  for c in ${c1//|/ }
    do
    printf "$f1 $f2 $c\n"
  done
  done |\
  awk '{print $1"\tGO\t"$3"\t\t"$2}' | sort -h | uniq > ${PREFIX}.${2}_go.tmp
}

extract_pathways(){
  cat ${1} | cut -f 1,9,15 ${INPUT} |\
  sed -e 's/:\s/:/g'|\
  while read -r f1 f2 c1
  do
  for c in ${c1//|/ }
    do
    printf "$f1 $f2 $c\n"
  done
  done |\
  sed -e 's/\s/\t/g' | sed 's/:/\t/g' |\
  awk '{print $1 "\t" $3 "\t" $4 "\t\t" $2}' | sort -h | uniq > ${PREFIX}.${2}_pathways.tmp
}

extract_ipr(){
  cat ${1} | awk -F '\t' '{OFS="\t" ; $12 ~ "IPR"}; {print $1 "\tInterPro\t" $12 "\t" $13 "\t" $9}' | sort -h | uniq > ${PREFIX}.${2}_ipr.tmp
}

if [[ -z $DATABASES ]]; then
  DATABASES=( $( cut -f4 ${INPUT} | sort | uniq ) )
fi

for i in ${DATABASES[@]}; do
  extract_dbs ${INPUT} ${OUTPUT} ${i}
done

if [[ $GOTERMS == true ]]; then
  extract_go ${INPUT} ${OUTPUT}
fi

if [[ $PATHWAYS == true ]]; then
  extract_pathways ${INPUT} ${OUTPUT}
fi

if [[ $IPR == true ]]; then
  extract_ipr ${INPUT} ${OUTPUT}
fi

if [[ $SPLIT == true ]]; then
  for tmp in ${PREFIX}.${OUTPUT}_*.tmp; do
    OUTFILE=${tmp##${PREFIX}.}
    echo -e "gene_callers_id\tsource\taccession\tfunction\te_value" > ${OUTFILE%.tmp}.tsv
    cat ${tmp} | awk -F '\t' '$5=="-" {OFS="\t" ; $5=""} 1' >> ${OUTFILE%.tmp}.tsv
    rm ${tmp}
  done
else
  echo -e "gene_callers_id\tsource\taccession\tfunction\te_value" > ${OUTPUT}_iprs2anvio.tsv
  cat ${PREFIX}.${OUTPUT}_*.tmp | awk -F '\t' '$5=="-" {OFS="\t" ; $5=""} 1' >> ${OUTPUT}_iprs2anvio.tsv
  rm ${PREFIX}.${OUTPUT}_*.tmp
fi


echo "DONE"
