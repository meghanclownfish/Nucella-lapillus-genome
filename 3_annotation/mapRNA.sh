#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --time 0-02:00
#SBATCH --mem=100G
#SBATCH --partition=short
#SBATCH --mail-user=ford.meg@northeastern.edu

cd /work/Trussell_Lab/nucella_genome/rna_seq


module purge 
module load hisat2/2.2.0 samtools/1.10

echo "starting le job"


hisat2-build -p 30 /work/Trussell_Lab/nucella_genome/new_hifiasm_2kb.a_ctg.filtered.fa.masked new_hifiasm_masked


echo "mapping"

hisat2 -x new_hifiasm_masked --dta -p 30 -q \
-U SRR1752284_trimmed.fq,SRR1752285_trimmed.fq,SRR1752286_trimmed.fq,SRR1752287_trimmed.fq,SRR1752288_trimmed.fq,SRR1752289_trimmed.fq,SRR1752290_trimmed.fq,SRR1752291_trimmed.fq,SRR999591_trimmed.fq -S v2_all_mapped_rna.sam


samtools view -u v2_all_mapped_rna.sam | samtools sort -o v2_all_mapped_rna.bam
