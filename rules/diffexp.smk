def get_contrast(wildcards):
    return config["diffexp"]["contrasts"][wildcards.contrast]

diff_Name='{contrast}'

rule deseq2:
    input:
        quant_files = expand(join(quant_dir,'{sample}','quant.sf'),
               sample=samples.Sample),
    output:
        deseq2_rds=join(diff_dir,diff_Name+'.deseq2.rds'),
        deseq2_res=join(diff_dir,diff_Name+'.DESeq2_res.tsv'),
        deseq2_exp=join(diff_dir,diff_Name+'.DESeq2_exp.tsv')
    params:
        contrast =get_contrast,
        meta = config['meta'],
        Name=diff_Name,
        gtf=config['ref']['annotation'],
        outdir=directory(diff_dir)
    threads: global_thread
    log:
        join(log_dir,"deseq2",diff_Name+".deseq2.log")
    script:
        "../scripts/deseq2.R"


rule output:
    input:
        deseq2_rds=join(diff_dir,diff_Name+'.deseq2.rds'),
        deseq2_res=join(diff_dir,diff_Name+'.DESeq2_res.tsv'),
        deseq2_exp=join(diff_dir,diff_Name+'.DESeq2_exp.tsv')
    output:
        join(report_dir,diff_Name+".DE.report.html")
    params:
        contrast =get_contrast,
        Name=diff_Name,
        outdir=directory(diff_dir),
        logFC_threshold=config["diffexp"]['logFC_threshold'],
        padj_threshold=config["diffexp"]['padj_threshold'],        
    log:
        join(log_dir,"deseq2",diff_Name+".output.log")
    script:
        "../scripts/output.Rmd"
