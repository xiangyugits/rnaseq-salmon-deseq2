log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

library(tximport)
library(readr)
#library(EnsDb.Hsapiens.v86)
library(stringr)
library(DESeq2)
library(dplyr)
library(tidyverse)
library(rtracklayer)

#配置
parallel <- FALSE
if (snakemake@threads > 1) {
    library("BiocParallel")
    register(MulticoreParam(snakemake@threads))
    parallel <- TRUE
}

allfiles <- snakemake@input[['quant_files']]
contrast<-snakemake@params[['contrast']]
meta<-read.table(snakemake@params[['meta']],header=T,sep='\t')
gtf<-snakemake@params[['gtf']]

gtfinfo<-rtracklayer::import(gtf)

#按照meta中Group分组输出差异分析结果
names(allfiles)<- basename(dirname(allfiles))
meta$Condition <- factor(meta$Condition)
meta$Group <- factor(meta$Group)
rownames(meta) <- meta$Sample
samples<-meta%>%
    tibble::as_tibble()%>%
    dplyr::filter(Condition%in%contrast)
print(samples)

files=allfiles[samples$Sample]

tx2gene <- gtfinfo%>%
  tibble::as_tibble() %>% 
  dplyr::select(c(transcript_id,gene_id))%>%
  drop_na()%>%
  distinct()
colnames(tx2gene)<-c("TXNAME",'GENEID')

if (!all(file.exists(files))){
  print(files)
}

save.image()


txi <- tximport(files, type="salmon", tx2gene=tx2gene,ignoreTxVersion=T)

#@@@@@@@@@@@@@@@@差异分析@@@@@@@@@@@@@@@@@@@@@@@#
ddsTxi <- DESeqDataSetFromTximport(txi,colData = samples,design = ~ Condition)
ref=contrast[1]
ddsTxi$Condition <- relevel(ddsTxi$Condition, ref = ref)
if (length(contrast)>2){
    dds <- DESeq(ddsTxi, parallel=parallel)
}else{
    dds <- DESeq(ddsTxi,parallel=TRUE,test='LRT',reduced=~1)
}
#@@@@@@@@@@@@@@@@获取结果、ID转换@@@@@@@@@@@@@@@@@@@@@@@#



geneMaptmp <- gtfinfo %>% 
  tibble::as_tibble() %>% 
  dplyr::filter(type=="gene") 
if ('gene_name' %in% colnames(geneMaptmp)){
  geneMap<-geneMaptmp%>%
          dplyr::select(c(gene_name,gene_id)) 
}else if ('gene_symbol' %in% colnames(geneMaptmp)){
  geneMap<-geneMaptmp%>%
          dplyr::select(c(gene_symbol,gene_id))
} else{
  geneMap<-geneMaptmp%>%
        dplyr::select(c(gene_id,gene_id))
}
colnames(geneMap)<-c("gene_name",'gene_id')

id_trans <-function(data_input){
  data_input <-data_input%>%
    as.data.frame()%>%
    tibble::rownames_to_column(var='gene') %>% 
    dplyr::left_join(geneMap,by=c('gene'='gene_id'))%>% 
    dplyr::select(gene,gene_name, everything())
} 

get_result<-function(dds,resultname){
  #res <- results(dds, contrast=contrast,  parallel=parallel)
  res <- lfcShrink(dds, coef=resultname, type="apeglm",parallel=parallel)
  res%>%
    id_trans()%>%
    mutate(contrast=resultname)
}

if (length(resultsNames(dds))>2){
    test<-'LRT'
}else{
    test<-'Wald'
}
name=resultsNames(dds)[2]
res=get_result(dds,name)
if (test=='LRT'){
  for (i in 3:length(resultsNames(dds))){
    name=resultsNames(dds)[i]
    tmp=get_result(dds,name)
    res<-res%>%
        bind_rows(tmp)
  }
}

#@@@@@@@@@@@@@@@@表达矩阵@@@@@@@@@@@@@@@@@@@@@@@#

## 输出矫正后表达量，样本量小于30时采用rlog进行转化，否则采用vsd
if (dim(colData(dds))[1]<30){
    ndds <- rlog(dds, blind=FALSE)
} else {
    ndds <- vst(dds, blind=FALSE)
}
exp <- as.data.frame(assay(ndds)) %>% 
  id_trans() %>% 
  type_convert()


#@@@@@@@@@@@@@@@@输出@@@@@@@@@@@@@@@@@@@@@@@#

Name <-snakemake@params[['Name']]
outdir<-snakemake@params[['outdir']]
outdir<-paste0(outdir,'/')
DESeq2_res_file=paste0(outdir,Name,'.DESeq2_res.tsv')
exp_file=paste0(outdir,Name,'.DESeq2_exp.tsv')
meta_file=paste0(outdir,Name,'.DESeq2_meta.tsv')

write_tsv(samples,meta_file)
write_tsv(exp,exp_file)
write_tsv(res,DESeq2_res_file)
saveRDS(ndds, file=snakemake@output[['deseq2_rds']])




