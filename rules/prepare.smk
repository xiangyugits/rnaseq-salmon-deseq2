
rule salmon_index:
    input:
        config['ref']['trans_fasta']
    output:
        directory(join("resource","salmon_index"))
    log:
        join(log_dir,"salmon","salmon_index.log")
    threads: 20
    cache:True
    params:
        extra=""
    wrapper:
        "0.60.7/bio/salmon/index"

