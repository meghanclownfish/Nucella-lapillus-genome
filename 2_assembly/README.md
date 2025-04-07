# Data QC
Remove adapters and filter data for desired qualities: 

```
#remove adapters
porechop -i input_reads.fastq -o output_reads.fq

#filter reads for quality 
NanoFilt -q 5 output_reads.fq > all6_q5.fastq

#and length
seqkit -m 2000 -o all6_2kb.fastq -j10 output_reads.fq 
```

# Assemble with Hifiasm

```
#for me this ran overnight and was done in the morning
nohup hifiasm -t50 --ont -o ONT_2kb.asm all6_2kb.fastq > hifiasm.log 2>&1 &
```
# Evaluate with BUSCO

```
#extract primary contigs from fasta
awk '/^S/{print ">"$2;print $3}' ONT_2kb.asm.bp.p_ctg.gfa > hifiasm_2kb.p_ctg.fa 

#run BUSCO 
busco \
  -i /home/meghan/nucella_genome/hifiasm/hifiasm_2kb.p_ctg.fa \
  -o busco_hifi \
  -m genome \
 --metaeuk \
  -c 20 \
  -l metazoa_odb10
```

# Decontaminate with blast and blobtools
I identified mitogenome contigs by blasting against the mitogenome of Nucella already assembled (https://doi.org/10.1007/s00227-024-04424-3). Because this was lightweight, I ran it on Galaxy (https://usegalaxy.org/). This search identified three contigs (mito_contig.txt) that were removed.  

```
#remove mito contigs 
seqkit grep -v -f mito_contig.txt hifi_cleaned_barcode.bp.p_ctg.fa -o hifi_cleaned_barcode_no_mito_ctg.fa
```

![image](https://github.com/user-attachments/assets/f0095271-512d-43bf-b98e-410a6ff94eed)




