#https://github.com/Gaius-Augustus/BRAKER/issues/609

singularity build braker3.sif docker://teambraker/braker3:latest

#activate conda env with singularity
conda activate repeatmodeler_env

#run braker3
nohup singularity exec -B /home/meghan/nucella_genome/annotate/no_scaffold/v1_braker /home/meghan/braker3.sif braker.pl \
--genome=/home/meghan/nucella_genome/annotate/no_scaffold/hifi_2kb_decontaminated.fa.masked \
--species=v1_nucella  --softmasking --threads=35 \
--prot_seq=/home/meghan/nucella_genome/database/eukaryota_and_molluscan_protien.fasta \
--bam=/home/meghan/nucella_genome/annotate/no_scaffold/all_mapped_rna.bam \
--AUGUSTUS_CONFIG_PATH=/home/meghan/config &

#run TSEBRA 
singularity exec /home/meghan/braker3.sif tsebra.py \
-g /home/meghan/nucella_genome/annotate/no_scaffold/braker/GeneMark-ETP/genemark.gtf \
-k /home/meghan/nucella_genome/annotate/no_scaffold/braker/Augustus/augustus.hints.gtf \
-e /home/meghan/nucella_genome/annotate/no_scaffold/braker/hintsfile.gff \
-c no_enforcement.cfg -o aug_enforcement.gtf 

# keep longest iso and extract protein seq
agat_sp_keep_longest_isoform.pl -f aug_enforcement.gtf -o iso_filt_aug_enforcement.gtf 

# 9597 L2 isoforms with CDS removed (shortest CDS)

# extract prot seq 
agat_sp_extract_sequences.pl -g iso_filt_aug_enforcement.gtf \
-f /home/meghan/nucella_genome/annotate/no_scaffold/hifi_2kb_decontaminated.fa.masked \
-o iso_filt_aug_enforcement.faa -p
