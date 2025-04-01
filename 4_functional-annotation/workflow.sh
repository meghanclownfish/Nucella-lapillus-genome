## filter isoforms and incomplete gene models
conda activate repeatmodeler_env
singularity run /home/meghan/agat_1.4.2--pl5321hdfd78af_0.sif 

#longest iso
singularity exec /home/meghan/braker3.sif rename_gtf.py --gtf braker_longest_insoforms.gtf --out braker_longest_insoforms_renamed.gtf

#format
singularity exec /home/meghan/braker3.sif gtf2gff.pl < braker_longest_insoforms_renamed.gtf  --gff3 --out braker_longest_insoforms_renamed.gff3

#fic overlap
agat_sp_fix_overlaping_genes.pl -f braker_longest_insoforms_renamed.gff3  -o fixed_overlap_braker_longest_insoforms_renamed.gff3
#761 genes overlap

#check they were removed 
agat_sq_stat_basic.pl -i braker_longest_insoforms_renamed.gff3 #(69715 genes)

agat_sq_stat_basic.pl -i fixed_overlap_braker_longest_insoforms_renamed.gff3  #(68954 genes)

#filter incomplete
agat_sp_filter_incomplete_gene_coding_models.pl --gff fixed_overlap_braker_longest_insoforms_renamed.gff3 --fasta /home/meghan/nucella_genome/annotate/v2_nucella/new_hifiasm_2kb.a_ctg.filtered.fa.masked -o remove_incomplete_fixed_overlap_braker_longest_insoforms_renamed.gff3

#(868 genes removed)

#get proteome
agat_sp_extract_sequences.pl -g remove_incomplete_fixed_overlap_braker_longest_insoforms_renamed.gff3 -f /home/meghan/nucella_genome/annotate/v2_nucella/new_hifiasm_2kb.a_ctg.filtered.fa.masked  -o remove_incomplete_fixed_overlap_braker_longest_insoforms_renamed.faa --clean_internal_stop -p

#68847 cds converted in fasta.


############## add function

conda activate busco_env

busco \
  -i remove_incomplete_fixed_overlap_braker_longest_insoforms_renamed.faa \
  -o busco_new_harsh\
  -m protein \
  -c 35 \
  -l metazoa_odb10 

#INTERPRO 
#remove stop codon
sed -i "s/*$//" remove_incomplete_fixed_overlap_braker_longest_insoforms_renamed.faa

nohup singularity exec \
    -B $PWD/interproscan-5.73-104.0/data:/opt/interproscan/data \
    -B $PWD/input:/input \
    -B $PWD/temp:/temp \
    -B $PWD/output:/output \
    interproscan_5.73-104.0.sif \
    /opt/interproscan/interproscan.sh \
--cpu 35 \
    --input /input/remove_incomplete_fixed_overlap_braker_longest_insoforms_renamed.faa\
    --disable-precalc \
-iprlookup \
--goterms \
    --output-dir /output \
    --tempdir /temp \
-appl TIGRFAM,Pfam, CDD &

############# now on @firefly

export FUNANNOTATE_DB=/home/meghan/fun_db

funannotate annotate --gff /home/meghan/remove_incomplete_fixed_overlap_braker_longest_insoforms_renamed.gff3 --fasta /home/meghan/Nucella_lapillus_genome.fsa --species "Nucella lapillus" --out fun_noEgg_harsh_filter --iprscan /home/meghan/remove_incomplete_fixed_overlap_braker_longest_insoforms_renamed.faa.xml --rename ACOMHN --busco_db metazoa --cpus 35 --sbt /home/meghan/template.sbt 

conda activate repmodel
singularity run ../entap.sif

EnTAP --run -i ../remove_incomplete_fixed_overlap_braker_longest_insoforms_renamed.faa -t 35
