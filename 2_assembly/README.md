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
#for me this ran overnight and was done in the morning
nohup hifiasm -t50 --ont -o ONT_2kb.asm all6_2kb.fastq > hifiasm.log 2>&1 &
```
