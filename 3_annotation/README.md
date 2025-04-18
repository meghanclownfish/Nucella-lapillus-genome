![image](https://github.com/user-attachments/assets/15340fb5-dfc1-4994-8fbf-668ffb1d43cc)
# Workflow
1. identify and mask repeats
2. map RNA to masked genome 
3. Braker3
4. TSEBRA
5. Interproscan/ Funannotate


## Identify repeats
```
conda activate repeatmodeler_env

#RepeatModeler (version = 2.0.6) pull image
singularity pull dfam-tetools-latest.sif docker://dfam/tetools:latest

#build database
singularity run ../dfam-tetools-latest.sif
BuildDatabase -name nucella_genome_april nlap_genome_no_mito_no_bac.filtered.fasta 

#start an instance 
singularity instance start ../dfam-tetools-latest.sif run_rm

#run repeat modeler, this took ~95 hours 
nohup singularity exec instance://run_rm RepeatModeler -LTRStruct -database nucella_genome_april -threads 45 &

```

## Mask repeats

```
#this took ~12 hours
nohup singularity exec instance://run_rm RepeatMasker -pa 35 -lib nucella_genome_april-families.fa -xsmall \
-gff nlap_genome_no_mito_no_bac.filtered.fasta &
```

## Map RNAseq data
These two steps took one hour. 

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
nohup singularity exec -B /home/meghan/nucella_genome/annotate/v3_nucella_april/braker /home/meghan/braker3.sif braker.pl \
--genome=/home/meghan/nucella_genome/annotate/v3_nucella_april/nlap_genome_no_mito_no_bac.filtered.fasta.masked \
--species=nLapillus  --softmasking --threads=30 \
--prot_seq=/home/meghan/nucella_genome/database/metazoa_and_mlluscan_protien.fasta \
--bam=/home/meghan/nucella_genome/annotate/v3_nucella_april/april_all_mapped_rna.bam \
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
### filtering
```
# longest isoform
singularity exec /home/meghan/braker3.sif get_longest_isoform.py --gtf aug_enforcement.gtf --out longest_insoforms.gtf

# convert to gff3
singularity exec /home/meghan/braker3.sif rename_gtf.py --gtf longest_insoforms.gtf --out longest_insoforms_renamed.gtf
singularity exec /home/meghan/braker3.sif gtf2gff.pl < longest_insoforms_renamed.gtf --out=longest_insoforms_renamed.gff3 --gff3


singularity run /home/meghan/agat_1.4.2--pl5321hdfd78af_0.sif

#overlapping
agat_sp_fix_overlaping_genes.pl -f longest_insoforms_renamed.gff3  -o v2_fixed_overlap_longest_insoforms_renamed.gff3

#388 genes overlap no_exon_longest_insoforms_renamed.gff3

#incomplete
agat_sp_filter_incomplete_gene_coding_models.pl --gff v2_fixed_overlap_longest_insoforms_renamed.gff3 --fasta /home/meghan/nucella_genome/annotate/v3_nucella_april/nlap_genome_no_mito_no_bac.filtered.fasta.masked -o v2_remove_incomplete_fixed_overlap_longest_insoforms_renamed.gff3

#Number of genes affected: 969
```

## Interproscan
```
nohup singularity exec \
    -B $PWD/interproscan-5.73-104.0/data:/opt/interproscan/data \
    -B $PWD/input:/input \
    -B $PWD/temp:/temp \
    -B $PWD/output:/output \
    interproscan_5.73-104.0.sif \
    /opt/interproscan/interproscan.sh \
--cpu 35 \
    --input /input/agat_braker_longest_insoforms_fixed_ids.faa\
    --disable-precalc \
-iprlookup \
--goterms \
    --output-dir /output \
    --tempdir /temp \
-appl TIGRFAM,Pfam, CDD &
```


## Funannotate
```
nohup funannotate annotate --gff /home/meghan/v3_nucella_genome/v2_remove_incomplete_fixed_overlap_longest_insoforms_renamed.gff3 --fasta /home/meghan/v3_nucella_genome/nlap_genome_no_mito_no_bac.filtered.fasta --species "Nucella lapillus" --out fun_noEgg_v2_0f_v3 --iprscan /home/meghan/v3_nucella_genome/v2_remove_incomplete_fixed_overlap_agat_longest_isoforms.faa.xml --rename ACOMHN --busco_db metazoa --cpus 35 --sbt /home/meghan/template.sbt &
```

<img width="319" alt="Screenshot 2025-03-12 at 3 41 40 PM" src="https://github.com/user-attachments/assets/180161dc-8bf1-43ff-ba51-fef8734f33e0" />
