#!/usr/bin/bash
#################################################################################################
#	This script pars a using a range of genes: gene and cds information and gives a table with GenomeID, ID, Start,END
#	strand, GeneID, GeneNAme, Product and ProtID
#	Dependencies perl, parstotal.pl R, _pars.gff.R, tidyverse
#	Author Arturo Vera
#	May 2020
#################################################################################################
file=$1
AssID=$2
start=$3
end=$4
locuscomm=$5

print_usage() {
	echo "Usage: $0 gffFIle AssemblyIDInit Start End LoccusCommon"
	echo "Example: $0 S.mell.kc3.GCF_000236085.2_SpiMel2.0_genomic.gff NZ 670 690 SPM_RS00"
	
}
if [  $# -le 1 ] 
	then 
		print_usage
		exit 1
	fi 

genomename=$(echo $file|awk '{split($0,a,".G"); print a[1]}')
echo "Parsing genes"
for((i=$start;i<$end+1;i++)); 
	do 
	grep $locuscomm${i} $file|\
		awk -F "\t" '{if($3 ~ /gene/) print}' ;
done > $file.gene
echo "parsing CDS"
for((i=$start;i<$end+1;i++));
        do
        grep $locuscomm${i} $file|\
                awk -F "\t" '{if($3 ~ /CDS/) print}' ;
done > $file.cds
perl parstotal.pl $file.gene $file.cds $AssID $genomename

echo -E "Final table" $file".gene.tab"
rm tmp*
rm *.gene
rm *.cds

