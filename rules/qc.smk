rule fastqc:
    input:
        lambda wildcards:samples.loc[wildcards.Sample,['fq1','fq2']]
    output:
        zip1=join(qc_dir,"{Sample}_R1_fastqc.zip"),
        zip2=join(qc_dir,"{Sample}_R2_fastqc.zip")
    shell:
        "fastqc {input} -o %s -t %s"%(qc_dir,global_thread)

rule multiqc:
    input:
        expand("{outdir}/{sample}_R{read}_fastqc.zip",outdir=qc_dir,sample= samples.Sample,read=[1,2])
    output:
        join(qc_dir,"multiqc_report.html")
    wrapper:
        "0.60.7/bio/multiqc"