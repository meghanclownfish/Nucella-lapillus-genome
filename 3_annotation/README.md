# workflow
1. repeats 
2. Braker3
3. EnTAP

<img width="319" alt="Screenshot 2025-03-12 at 3 41 40 PM" src="https://github.com/user-attachments/assets/180161dc-8bf1-43ff-ba51-fef8734f33e0" />


# identify repeats
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

# mask repeats

```
#this took about 5 houts
nohup singularity exec instance://run_rm RepeatMasker -pa 35 -lib ../nucella_genome-families.fa -xsmall \
-gff ../hifi_2kb_decontaminated.fa &
```

# map RNAseq data

## first build a HISAT2 library 

```
hisat2-build -p 30 hifi_2kb_decontaminated.fa.masked hifiasm_masked
```
## mapping 
```
hisat2 -x new_hifiasm_masked --dta -p 30 -q -U \
SRR1752284_trimmed.fq,SRR1752285_trimmed.fq,SRR1752286_trimmed.fq,SRR1752287_trimmed.fq,\
SRR1752288_trimmed.fq,SRR1752289_trimmed.fq,SRR1752290_trimmed.fq,SRR1752291_trimmed.fq,\
SRR999591_trimmed.fq -S v2_all_mapped_rna.sam
```
