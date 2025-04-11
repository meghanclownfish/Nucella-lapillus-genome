# Data QC
Remove adapters and filter data for desired qualities: 

```
#remove adapters
porechop -i input_reads.fastq -o all6_harsh_chop.fastq --threads 45 --check_reads 40000 --adapter_threshold 85 --middle_threshold 85

#filter reads for quality (this takes longer than filtering for length)
nohup seqkit seq -Q 5 -o all6_harsh_chop_q5.fastq -j35 all6_harsh_chop.fastq &

#and length
seqkit -m 2000 -o all6_2kb.fastq -j10 all6_harsh_chop_2kb.fastq 
```

# Assemble with Hifiasm

```
#for me this ran overnight and was done in the morning
nohup ../hifiasm  --ont -t 40 -o hifi_cleaned_barcode /home/meghan/nucella_genome/runs/all6_harsh_chop_2kb.fastq &
```
# Evaluate with BUSCO and SeqKit

```
#extract primary contigs from fasta
awk '/^S/{print ">"$2;print $3}' hifi_cleaned_barcode.bp.p_ctg.gfa  > hifi_cleaned_barcode.bp.p_ctg.fa 

#run BUSCO 
busco \
  -i /home/meghan/nucella_genome/hifiasm/hifiasm_2kb.p_ctg.fa \
  -o busco_hifi \
  -m genome \
 --metaeuk \
  -c 20 \
  -l metazoa_odb10

#seqkit stats
seqkit stats hifi_cleaned_barcode.bp.p_ctg.fa -j10
```
# Check for adapter contamination

```
./run_fcsadaptor.sh --fasta-input /home/meghan/nucella_genome/hifiasm/bp_trim_assemble/hifi_cleaned_barcode.bp.p_ctg.fa --output-dir ./output_fcs --euk --container-engine singularity --image fcs-adaptor.sif
```


# Decontaminate with blast and blobtools
I identified mitogenome contigs by blasting against the mitogenome of Nucella already assembled [here](https://doi.org/10.1007/s00227-024-04424-3). Because this was lightweight, I ran it on [Galaxy](https://usegalaxy.org/). This search identified three contigs (mito_contig.txt) that were removed. After this, I ran FCS GX on [Galaxy](https://usegalaxy.org/) as a first pass to remove any bacterial contaminants (output = nlap_genome_no_mito_no_bac.fasta).    

```
#remove mito contigs 
seqkit grep -v -f mito_contig.txt hifi_cleaned_barcode.bp.p_ctg.fa -o hifi_cleaned_barcode_no_mito_ctg.fa

#FCS GX on galaxy

#blobtools
#create directory
blobtools create \
      --fasta /home/meghan/nucella_genome/april_hifiasm/bp_trim_assemble/nlap_genome/nlap_genome_no_mito_no_bac.fasta \
      --taxid 51631 \
      --threads 50 \
      --taxdump ~/nucella_genome/database/taxdump \
~/nucella_genome/database/nucella_2kb_clean_noMito_noBac

#run BUSCO
nohup busco \
  -i nlap_genome_no_mito_no_bac.fasta\
  -o no_mito_no_bac_busco \
  -m genome \
 --metaeuk \
  -c 35 \
  -l metazoa_odb10 &

#and diamond (this was run on a different server, hence the different paths)
./diamond blastx \
        --query /work/Trussell_Lab/no_adapter/nlap_genome_no_mito_no_bac.fasta \
        --db /work/Trussell_Lab/database/reference_proteomes.dmnd \
        --outfmt 6 qseqid staxids bitscore qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore \
        --log \
        --faster \
        --max-target-seqs 1 \
        --evalue 1e-25 \
        --threads 50 \
        --out fast_hifi_cleaned_barcode.diamond.blastx.out


#add busco and hits to blobtools 
blobtools add \
--busco /home/meghan/nucella_genome/april_hifiasm/bp_trim_assemble/nlap_genome/no_mito_no_bac_busco.tsv \
--hits /home/meghan/nucella_genome/april_hifiasm/bp_trim_assemble/nlap_genome/fast_hifi_cleaned_barcode.diamond.blastx.out \
--threads 35 \
--taxdump ~/nucella_genome/database/taxdump \
~/nucella_genome/database/nucella_2kb_clean_noMito_noBac

#visually inspect
blobtools view --remote ~/nucella_genome/database/nucella_2kb_clean_noMito_noBac/

#filter
blobtools filter \
     --json nucella_2kb_clean_noMito_noBac.current.json\
     --fasta nlap_genome_no_mito_no_bac.fasta \
     --output nucella_2kb_clean_noMito_noBac_FILTERED \
     --summary STDOUT ~/nucella_genome/database/nucella_2kb_clean_noMito_noBac

```
# Check new filtered assembly with BUSCO and SeqKit

```
nohup busco \
  -i nlap_genome_no_mito_no_bac.filtered.fasta\
  -o busco_april_final \
  -m genome \
 --metaeuk \
  -c 35 \
  -l metazoa_odb10 &

seqkit stats nlap_genome_no_mito_no_bac.filtered.fasta -j25

```


![image](https://github.com/user-attachments/assets/f0095271-512d-43bf-b98e-410a6ff94eed)




