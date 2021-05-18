# RNA-seq workflow

# 1. 基本信息 

流程管理 : **snakemake**


# 2 主要软件


| 软件            | 版本 | 功能         |
| :-------------- | :--- | :----------- |
| mulitqc         |      | 数据质控     |
| salmon          |      | RNA-Seq 定量 |
| DEseq2          |      | 差异分析     |



# 3 概要设计

## 3.1 目录及参数文件设计

#### 3.1.1 目录
```sh
.
├── README.md    #流程描述文件
├── config.yaml  #流程参数文件
├── samples.tsv  #fastq 信息
├── meta.tsv     #样本分组信息文件
├── schemas      #参数配置文件规范
│   ├── config.schema.yaml
│   ├── samples.schema.yaml
│   └── meta.schema.yaml
├── fastq        #存储数据软链接
├── report       #存储报告
├── result       #存储中间文件
│   ├── 01_qc
│   ├── 02_quant
│   ├── 03_diffexp
│   ├── 04_wgcna
│   └── 05_enrich
├── rules        #各部分流程snakefile  
│   ├── qc.smk
│   ├── quant.smk
│   ├── diffexp.smk
│   ├── wgcna.smk
│   ├── enrich.smk
│   └── report.smk
├── scripts      #存储python R脚本
└── Snakefile    #main snakefile
```
#### 3.1.2 config.yaml 

```sh
#项目名称
PROJECT: 

#项目负责人
PERSON: 

#实验、文库信息
LIBRARYINFO: config/libraryinfo.tsv 

####################
# 输入输出
####################

#数据信息表
meta: meta.tsv

#样品信息表
samples: samples.tsv

#数据路径
DATA_DIR: fastq/

#输出路径
working_dir: result/ #工作目录
report_dir: report/  #报告路径


####################
# 分析参数
####################

#参考基因信息
ref:
  # 索引文件
  index: 
  # 注释文件
  annotation: 

# 差异分析时使用的对比组。
diffexp:
  contrasts:
    treated-vs-untreated:
      - treated
      - untreated

```
#### 3.1.3 meta.tsv

```sh
<sample>  <condition>
 A          treated
 B          untreated
```

#### 3.1.4 samples.tsv

```sh
<sample> <read1.fq> <read2.fq>
 A          fq1       fq2
 A          fq1       fq2
 B          fq1       fq2     

```
