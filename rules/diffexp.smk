def get_contrast(wildcards):
    return config["diffexp"]["contrasts"][wildcards.contrast]

diff_Name='{contrast}'

rule deseq2:
    input:
        quant_rds=join(quant_dir,'txi.rds')
    output:
        table=report(join(diff_dir,"{contrast}.diffexp.tsv"), join(report_dir,"diffexp.rst")),
        ma_plot=report(join(diff_dir,"{contrast}.ma-plot.svg"), join(report_dir,"ma.rst")),
    params:
        contrast = get_contrast,
        meta = config['meta']
    threads: global_thread
    log:
        join(log_dir,"deseq2","{contrast}.diffexp.log")

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
        anno_db=config["ref"]["anno_db"],
        #outdir=directory(diff_dir),
        logFC_threshold=config["diffexp"]['logFC_threshold'],
        padj_threshold=config["diffexp"]['padj_threshold'],        
    log:
        join(log_dir,"deseq2",diff_Name+".output.log")
    script:
        "../scripts/output.Rmd"
