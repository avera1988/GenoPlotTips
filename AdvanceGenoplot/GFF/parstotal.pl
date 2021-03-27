#!/usr/bin/perl -w
#################################################################################################
#	This script pars a gene and cds information and gives a table with GenomeID, ID, Start,END
#	strand, GeneID, GeneNAme, Product and ProtID
#	Dependencies R, tidyverse
#	bash
#	Author Arturo Vera
#	May 2020
#################################################################################################

use strict;

@ARGV ==4 || die("usage: perl $0 GffgeneFile GFFCDSfile Conting_ScaffoldName GenomeName");

my(@col,@annot,@ID,@gene,@product,@protid);
my($gff,$cds,$common,$genomename)=@ARGV;

open(GFF,$gff);
open(TMP,">tmp1");
while(<GFF>){
	chomp;
	if($_ =~ /^$common/){
	@col=split(/\t/);
	foreach($col[8]){
		@annot=split(/\;/);
		@ID=grep(/^ID/,@annot);
		for(@ID){
			s/ID=gene-//;
		}
		@gene=grep(/^Name/,@annot);
		for(@gene){
			s/Name=//;
		}
	}
	print TMP "$genomename\t$col[0]\t$col[3]\t$col[4]\t$col[6]\t@ID\t@gene\n";
 }
}
close(TMP);
open(CDS,$cds);
open(TMP2, ">tmp2");
while(<CDS>){
		chomp;
	if($_ =~ /^$common/){
	@col=split(/\t/);
	foreach($col[8]){
		@annot=split(/\;/);
		@ID=grep(/^ID/,@annot);
		for(@ID){
			s/ID=//;
		}
		@gene=grep(/^Parent/,@annot);
		for(@gene){
			s/Parent=gene-//;
		}
		@product=grep(/^product/,@annot);
		for(@product){
			s/product=//;
		}
		@protid=grep(/^protein_id/,@annot);
		for(@protid){
			s/protein_id=//;
		}
	}
	print TMP2 "@gene\t@product\t@protid\n";

 }
}
close(TMP2);
my $a='tmp1';
my $b='tmp2';
my $c=$gff.'.tab';
my @commandR = ("Rscript", "_pars.gff.R",$a,$b,$c);
system(@commandR);

