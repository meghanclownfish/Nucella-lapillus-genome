![image](https://github.com/user-attachments/assets/15340fb5-dfc1-4994-8fbf-668ffb1d43cc)
# Workflow
1. identify and mask repeats
2. map RNA to masked genome 
3. Braker3
4. TSEBRA
5. EnTAP/ Interproscan


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

```
#run braker3
nohup singularity exec -B /home/meghan/nucella_genome/annotate/no_scaffold/v1_braker /home/meghan/braker3.sif braker.pl \
--genome=/home/meghan/nucella_genome/annotate/no_scaffold/hifi_2kb_decontaminated.fa.masked \
--species=v1_nucella  --softmasking --threads=35 \
--prot_seq=/home/meghan/nucella_genome/database/eukaryota_and_molluscan_protien.fasta \
--bam=/home/meghan/nucella_genome/annotate/no_scaffold/all_mapped_rna.bam \
--AUGUSTUS_CONFIG_PATH=/home/meghan/config &
```

## TSEBRA
```
#run TSEBRA
singularity exec /home/meghan/braker3.sif tsebra.py \
-g /home/meghan/nucella_genome/annotate/no_scaffold/braker/GeneMark-ETP/genemark.gtf \
-k /home/meghan/nucella_genome/annotate/no_scaffold/braker/Augustus/augustus.hints.gtf \
-e /home/meghan/nucella_genome/annotate/no_scaffold/braker/hintsfile.gff \
-c no_enforcement.cfg -o aug_enforcement.gtf 
```
### keep only the longest isoform
```

```


## EnTAP
```
#entap with uniprot_sprot an refseq_invertebrarte

singularity run ../entap.sif

#configure
EnTAP --config --run-ini entap_run.params --entap-ini entap_config.ini -t 5

#update all paths in parms and ini with given info before moving on. For eggNog SQL database
#include path but not file (EnTap will not understand if you give file) 

#run entap
EnTAP --run -i iso_filt_aug_enforcement.faa -t 35
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

<img width="319" alt="Screenshot 2025-03-12 at 3 41 40 PM" src="https://github.com/user-attachments/assets/180161dc-8bf1-43ff-ba51-fef8734f33e0" />
