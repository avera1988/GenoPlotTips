library(tidyverse)
args <- commandArgs(TRUE)


gene <- args[1]
cds <- args[2]
out <- args[3]

geneTab <- read.delim(gene,sep="\t",header=F)
colnames(geneTab) <- c("Genome","ID","Start","End","Strand","Gene_id","Gene")
cdsTab <- read.delim(cds,sep="\t",header=F)
colnames(cdsTab) <- c("Gene_id","Product","ProtID")

TabPars <- full_join(geneTab,cdsTab, by="Gene_id")

TabPars <- TabPars %>%
  mutate(Gene=ifelse(grepl("hyp",Product),"hyp", as.character(TabPars$Gene)))

write.table(TabPars,out,sep="\t",row.names = F, quote=F)