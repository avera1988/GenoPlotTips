# This script produce a plot of the order of genes in a genomic segment usign 
# a GFF file and the genoPlotR http://genoplotr.r-forge.r-project.org/ libary
# Dependecies: genoplotR
#             tidiverse
# Files: GFF files with the DNA segments to plot
# Author: Arturo Vera
# avera@ccg.unam.mx
# May 2020
###################################################################

#Libraries
library(genoPlotR)
library(tidyverse)

#reading GFF tab files
filenames <- list.files(pattern = "*.tab")
myNames <- gsub("_.*","",gsub("\\.*","",filenames))
myreaddelim <- function(path){
  readr::read_delim(path,"\t",
                    escape_double = TRUE,
                    trim_ws = TRUE,
  )
}

list.data <- map(filenames,myreaddelim)
names(list.data) <- myNames

#Transform the GFF and add change some gene names acording literature
GFF <- reduce(list.data,rbind)

GFF <- GFF %>% mutate(Gene=ifelse(grepl("lhgO",Gene),"glpO",
                                  ifelse(grepl("aquaporin",Product),"glpF",GFF$Gene)))
#Funtion to plot the order of genes as arrow (blocks) and scaling using GenoPlot
PlotGenes <- function(IN){
  #Adding a column with color for each group of genes
  GFF <- mutate(GFF, color=ifelse(grepl("hyp",Gene),"Gray",
                                  ifelse(grepl("glpO",Gene),"yellowgreen",
                                         ifelse(grepl("glpF",Gene),"purple",
                                                ifelse(grepl("glpK",Gene),"orange",
                                                       ifelse(grepl("glpT",Gene),"Pink","Blue"))))))
  GFFnames <- unique(GFF$Genome)
  #Generating dataframe for each Genome
  getGFF <- function(x){
    mi <- GFF %>% filter(Genome==x)
    return(mi)
  }
  list.data<- lapply(GFFnames, getGFF)
  names(list.data) <- GFFnames
  #Function for segments of genes to be plotted
  DF <- function(x){
    DF.x <- data.frame(name=x$Gene,
                       start= x$Start,
                       end=x$End,
                       strand=x$Strand,
                       col=x$color)
  }
  #Obtaining segments
  for.segments <- lapply(list.data,DF)
  segment <- function(x){
    dna_seg.x <- dna_seg(x,fill =x$col,gene_type = "headless_arrows") #This generates a plot only showing blocks if arrows needed not use gene_type = "headless_arrows" argumment.
  }
  dna_segs <- lapply(for.segments,segment)
  
  #Adding annotations (i.e. gene names)
  annots <- lapply(dna_segs, function(x){
    mid <- middle(x)
    annot <- annotation(x1=mid, text=x$name)
  })
  #pdf(OUT,height = H,width = W) #Uncomment for saving as pdf
  plot_gene_map(dna_segs=dna_segs,
                annotations = annots,annotation_cex=0.7)
  #dev.off() #Uncoment for saving as pdf
}

#Run function using the GFF object generated above
PlotGenes(GFF)