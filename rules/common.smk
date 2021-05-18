
def get_fastq(wildcards):
    """Get fastq files of given sample."""
    fastqs = units.loc[(wildcards.Sample), ["fq1", "fq2"]].dropna()
    if len(fastqs) == 2:
        return {"r1": fastqs.fq1, "r2": fastqs.fq2}
    return {"r1": fastqs.fq1}

units.loc[:,'clean_fq1']=units.apply(lambda x:join(qc_dir,"trimmed",x.Sample+".R1.clean.fastq.gz"),axis=1)
units.loc[:,'clean_fq2']=units.apply(lambda x:join(qc_dir,"trimmed",x.Sample+".R2.clean.fastq.gz"),axis=1)


def get_trimmed_reads(wildcards):
    """Get trimmed reads of given sample"""
    fastqs = units.loc[(wildcards.Sample), ["clean_fq1", "clean_fq2"]].dropna()
    if len(fastqs) == 2:
        return {"fq1": fastqs.clean_fq1, "fq2": fastqs.clean_fq2}
    return {"fq1": fastqs.clean_fq1}


