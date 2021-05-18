import pandas as pd
from os.path import join
from snakemake.utils import validate, min_version

#configfile:'config.yaml'
validate(config,schema='schemas/config.schema.yaml')

meta=pd.read_table(config['meta']).set_index("Sample",drop=False)
validate(meta,schema='schemas/meta.schema.yaml')

samples = pd.read_table(config["samples"], dtype=str).set_index(["Sample"], drop=False)
validate(samples, schema="schemas/samples.schema.yaml")

work_dir=config['working_dir']
report_dir=config['report_dir']
log_dir =config['log_dir']

qc_dir=join(work_dir,'01_qc')
quant_dir=os.path.join(work_dir,'02_quant')
diff_dir=join(work_dir,'03_diffexp')

global_thread=config['threads']

##### target rules #####

rule all:
    input:
        #质控结果
        join(qc_dir,"multiqc_report.html"),
       
        #定量结果
        expand(join(quant_dir,'{sample}','quant.sf'),
               sample=samples.Sample),

        join(quant_dir,'quant.txt'),
       
        #差异分析结果
        expand(join(diff_dir,'{contrast}'+".DESeq2_res.tsv"),
               contrast=config["diffexp"]["contrasts"]),

        expand(join(report_dir,'{contrast}'+".DE.report.html"),
               contrast=config["diffexp"]["contrasts"]),
       
##### load rules #####

include: "rules/qc.smk"
include: "rules/quant.smk"
include: "rules/diffexp.smk"

