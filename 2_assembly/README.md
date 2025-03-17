# Data QC
Remove adapters and filter data for desired qualities: 

```
#remove adapters
porechop -i input_reads.fastq -o output_reads.fq

#filter reads for quality 
NanoFilt -q 10 output_reads.fq > all6_q10.fastq

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

<img width="350" alt="Screenshot 2025-03-17 at 12 22 44 PM" src="https://github.com/user-attachments/assets/5cb23bb0-0326-45a1-9daa-c965dd6146d0" />


