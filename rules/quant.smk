
rule salmon_index:
    input:
        config['ref']['trans_fasta']
    output:
        directory(join(quant_dir,"salmon","transcriptome_index"))
    log:
        join(log_dir,"salmon","transcriptome_index.log")
    threads: global_thread
    params:
        extra=""
    wrapper:
        "0.60.7/bio/salmon/index"

rule salmon_quant_reads:
    input:
        # If you have multiple fastq files for a single sample (e.g. technical replicates)
        # use a list for r1 and r2.
        r1 = lambda wildcards:samples.loc[wildcards.sample,'fq1'],
        r2 = lambda wildcards:samples.loc[wildcards.sample,'fq2'],
        index=join(quant_dir,"salmon","transcriptome_index")
    output:
        quant = join(quant_dir,'{sample}','quant.sf'),
        lib = join(quant_dir,'{sample}','lib_format_counts.json')
    log:
        join(log_dir,'salmon','{sample}'+'.log')
    params:
        # optional parameters
        libtype ="A",
        #zip_ext = bz2 # req'd for bz2 files ('bz2'); optional for gz files('gz')
        extra=""
    threads: global_thread
    wrapper:
        "0.60.7/bio/salmon/quant"

rule tximport:
    input:
        quant_files = expand(join(quant_dir,"{sample}",'quant.sf'),sample=samples.Sample)
    output:
        quant_matrix=join(quant_dir,'quant.txt')
    params:
        gtf=config['ref']['annotation']
    log:
        join(log_dir,'tximport.log')
    script:
        "../scripts/tximport.R"


rule star_pe_multi:
    input:
        # use a list for multiple fastq files for one sample
        # usually technical replicates across lanes/flowcells
        fq1 = ["reads/{sample}_R1.1.fastq", "reads/{sample}_R1.2.fastq"],
        # paired end reads needs to be ordered so each item in the two lists match
        fq2 = ["reads/{sample}_R2.1.fastq", "reads/{sample}_R2.2.fastq"] #optional
    output:
        # see STAR manual for additional output files
        "star/pe/{sample}/Aligned.out.sam"
    log:
        "logs/star/pe/{sample}.log"
    params:
        # path to STAR reference genome index
        index="index",
        # optional parameters
        extra=""
    threads: 8
    wrapper:
        "0.60.7/bio/star/align"



