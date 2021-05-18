
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



