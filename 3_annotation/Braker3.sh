#https://github.com/Gaius-Augustus/BRAKER/issues/609

singularity build braker3.sif docker://teambraker/braker3:latest

#activate conda env with singularity
conda activate repeatmodeler_env

#run braker3
nohup singularity exec -B /home/meghan/nucella_genome/annotate/v3_nucella_april/braker /home/meghan/braker3.sif braker.pl \
--genome=/home/meghan/nucella_genome/annotate/v3_nucella_april/nlap_genome_no_mito_no_bac.filtered.fasta.masked \
--species=nLapillus  --softmasking --threads=30 \
--prot_seq=/home/meghan/nucella_genome/database/metazoa_and_mlluscan_protien.fasta \
--bam=/home/meghan/nucella_genome/annotate/v3_nucella_april/april_all_mapped_rna.bam \
--AUGUSTUS_CONFIG_PATH=/home/meghan/config &

#run tsebra 

singularity exec /home/meghan/braker3.sif tsebra.py \
-g /home/meghan/nucella_genome/annotate/v3_nucella_april/braker/braker/GeneMark-ETP/genemark.gtf \
-k /home/meghan/nucella_genome/annotate/v3_nucella_april/braker/braker/Augustus/augustus.hints.gtf \
-e /home/meghan/nucella_genome/annotate/v3_nucella_april/braker/braker/hintsfile.gff \
--filter_single_exon_genes \
-c tsebra.cfg -o aug_enforcement.gtf 

#longest iso 

singularity exec /home/meghan/braker3.sif get_longest_isoform.py --gtf aug_enforcement.gtf --out longest_insoforms.gtf

#formatting 
singularity exec /home/meghan/braker3.sif rename_gtf.py --gtf longest_insoforms.gtf --out longest_insoforms_renamed.gtf
singularity exec /home/meghan/braker3.sif gtf2gff.pl < longest_insoforms_renamed.gtf --out=longest_insoforms_renamed.gff3 --gff3 

#fix overlap 
agat_sp_fix_overlaping_genes.pl -f longest_insoforms_renamed.gff3  -o v2_fixed_overlap_longest_insoforms_renamed.gff3

#filter incomplete
agat_sp_filter_incomplete_gene_coding_models.pl --gff v2_fixed_overlap_longest_insoforms_renamed.gff3 \
--fasta /home/meghan/nucella_genome/annotate/v3_nucella_april/nlap_genome_no_mito_no_bac.filtered.fasta.masked \
-o v2_remove_incomplete_fixed_overlap_longest_insoforms_renamed.gff3

#get proteome 
singularity run /home/meghan/agat_1.4.2--pl5321hdfd78af_0.sif

agat_sp_extract_sequences.pl -g v2_remove_incomplete_fixed_overlap_longest_insoforms_renamed.gff3 \
-f /home/meghan/nucella_genome/annotate/v3_nucella_april/nlap_genome_no_mito_no_bac.filtered.fasta.masked  \
-o v2_remove_incomplete_fixed_overlap_agat_longest_isoforms.faa --clean_internal_stop -p


