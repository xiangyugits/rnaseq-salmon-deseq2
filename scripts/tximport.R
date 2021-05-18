log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

library(tximport)
library(readr)
library(stringr)
library(dplyr)
library(tidyverse)

files <- snakemake@input[['quant_files']]
names(files)<- basename(dirname(files))

gtf<-snakemake@params[['gtf']]
gtfinfo<-rtracklayer::import(gtf)

tx2gene <- gtfinfo%>%
  tibble::as_tibble() %>% 
  dplyr::select(c(transcript_id,gene_id))%>%
  drop_na()%>%
  distinct()
colnames(tx2gene)<-c("TXNAME",'GENEID')

if (!all(file.exists(files))){
  print(files[!file.exists(files)])
}

txi <- tximport(files, type="salmon", tx2gene=tx2gene,ignoreTxVersion=T)

out<-as.data.frame(txi['abundance'])
colnames(out)<-str_replace(colnames(out),'abundance.','')
out=out[rowSums(out<0.1)<(dim(out)[2]*0.8),]

write.table(out,snakemake@output[['quant_matrix']],sep='\t',quote=F)
