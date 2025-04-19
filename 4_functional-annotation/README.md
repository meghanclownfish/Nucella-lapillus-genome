## get proteome for interpro

```
singularity run /home/meghan/agat_1.4.2--pl5321hdfd78af_0.sif

agat_sp_extract_sequences.pl -g v2_remove_incomplete_fixed_overlap_longest_insoforms_renamed.gff3 -f /home/meghan/nucella_genome/annotate/v3_nucella_april/nlap_genome_no_mito_no_bac.filtered.fasta.masked  -o v2_remove_incomplete_fixed_overlap_agat_longest_isoforms.faa --clean_internal_stop -p

```

## Interproscan
This is done in about 4 hours.
```
nohup singularity exec \
    -B $PWD/interproscan-5.73-104.0/data:/opt/interproscan/data \
    -B $PWD/input:/input \
    -B $PWD/temp:/temp \
    -B $PWD/output:/output \
    interproscan_5.73-104.0.sif \
    /opt/interproscan/interproscan.sh \
--cpu 40 \
    --input /input/v2_remove_incomplete_fixed_overlap_agat_longest_isoforms.faa \
    --disable-precalc \
-iprlookup \
--goterms \
    --output-dir /output \
    --tempdir /temp \
-appl TIGRFAM,Pfam, CDD &
```


## Funannotate

```
conda activate funannotate
export FUNANNOTATE_DB=/home/meghan/fun_db

nohup funannotate annotate --gff /home/meghan/v3_nucella_genome/v2_remove_incomplete_fixed_overlap_longest_insoforms_renamed.gff3 \
--fasta /home/meghan/v3_nucella_genome/nlap_genome_no_mito_no_bac.filtered.fasta \
--species "Nucella lapillus" \
--out fun_noEgg_v2_0f_v3 \
--iprscan /home/meghan/v3_nucella_genome/v2_remove_incomplete_fixed_overlap_agat_longest_isoforms.faa.xml \
--rename ACOMHN \
--busco_db metazoa \
--cpus 35 \
--sbt /home/meghan/template.sbt &
```

<img width="319" alt="Screenshot 2025-03-12 at 3 41 40 PM" src="https://github.com/user-attachments/assets/180161dc-8bf1-43ff-ba51-fef8734f33e0" />

