# remove adapters
porechop -i input_reads.fastq -o output_reads.fq

# filter reads for quality 
NanoFilt -q 5 output_reads.fq > all6_q5.fastq

# and length
seqkit -m 2000 -o all6_2kb.fastq -j10 output_reads.fq 

# assemble, for me this ran overnight and was done in the morning
nohup hifiasm -t50 --ont -o ONT_2kb.asm output_reads.fq > hifiasm.log 2>&1 &

# extract primary contigs from fasta
awk '/^S/{print ">"$2;print $3}' ONT_2kb.asm.bp.p_ctg.gfa > hifiasm_2kb.p_ctg.fa 

# run BUSCO 
busco \
  -i /home/meghan/nucella_genome/hifiasm/hifiasm_2kb.p_ctg.fa \
  -o busco_hifi \
  -m genome \
 --metaeuk \
  -c 10 \
  -l metazoa_odb10
