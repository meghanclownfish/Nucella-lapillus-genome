# Workflow
1. identify and mask repeats
2. map RNA to masked genome 
3. Braker3
4. TSEBRA
5. EnTAP/ Interproscan

<img width="319" alt="Screenshot 2025-03-12 at 3 41 40 PM" src="https://github.com/user-attachments/assets/180161dc-8bf1-43ff-ba51-fef8734f33e0" />


## Identify repeats
```
conda activate repeatmodeler_env

#RepeatModeler (version = 2.0.6) pull image
singularity pull dfam-tetools-latest.sif docker://dfam/tetools:latest

#build database
singularity run ../dfam-tetools-latest.sif
BuildDatabase -name nucella_genome hifi_2kb_decontaminated.fa 

#start an instance 
singularity instance start ../dfam-tetools-latest.sif run_rm

#run repeat modeler, this took ~92 hours 
nohup singularity exec instance://run_rm RepeatModeler -LTRStruct -database nucella_genome -threads 35 &

```

## Mask repeats

```
#this took about 5 hours
nohup singularity exec instance://run_rm RepeatMasker -pa 35 -lib ../nucella_genome-families.fa -xsmall \
-gff ../hifi_2kb_decontaminated.fa &
```

## Map RNAseq data
These two steps took less than two hours. 

```
#build the index 
hisat2-build -p 30 hifi_2kb_decontaminated.fa.masked hifiasm_masked

#mapping 
hisat2 -x hifiasm_masked --dta -p 30 -q -U \
SRR1752284_trimmed.fq,SRR1752285_trimmed.fq,SRR1752286_trimmed.fq,SRR1752287_trimmed.fq,\
SRR1752288_trimmed.fq,SRR1752289_trimmed.fq,SRR1752290_trimmed.fq,SRR1752291_trimmed.fq,\
SRR999591_trimmed.fq -S all_mapped_rna.sam
```

## Braker3
for more detail about this step, see [Braker3.sh](https://github.com/meghanclownfish/Nucella-lapillus-genome/blob/main/3_annotation/Braker3.sh) 
```
#run braker3
nohup singularity exec -B /home/meghan/nucella_genome/annotate/no_scaffold/v1_braker /home/meghan/braker3.sif braker.pl \
--genome=/home/meghan/nucella_genome/annotate/no_scaffold/hifi_2kb_decontaminated.fa.masked \
--species=v1_nucella  --softmasking --threads=35 \
--prot_seq=/home/meghan/nucella_genome/database/eukaryota_and_molluscan_protien.fasta \
--bam=/home/meghan/nucella_genome/annotate/no_scaffold/all_mapped_rna.bam \
--AUGUSTUS_CONFIG_PATH=/home/meghan/config &
```
## Interproscan
```
nohup singularity exec \
-B $PWD/interproscan-5.73-104.0/data:/opt/interproscan/data \
-B $PWD/input:/input \   
-B $PWD/temp:/temp\
-B $PWD/output:/output \
interproscan_5.73-104.0.sif\
/opt/interproscan/interproscan.sh --cpu 35\
--input /input/iso_filt_v2_aug_enforcement.faa\
--disable-precalc -iprlookup --goterms\
--output-dir /output\
--tempdir /temp &
```
