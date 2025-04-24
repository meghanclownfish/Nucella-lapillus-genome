#RepeatModeler (version = 2.0.6)
singularity pull dfam-tetools-latest.sif docker://dfam/tetools:latest

#activate conda env with singularity
conda activate repeatmodeler_env
singularity run ../dfam-tetools-latest.sif

BuildDatabase -name nucella_genome_april nlap_genome_no_mito_no_bac.filtered.fasta 

#start an instance 
singularity instance start ../dfam-tetools-latest.sif run_rm

#run repeat modeler, this took 94:54:20  (hh:mm:ss) 
nohup singularity exec instance://run_rm RepeatModeler -LTRStruct -database nucella_genome_april -threads 45 &

#run repeat masker, this took 12 hours 
nohup singularity exec instance://run_rm RepeatMasker -pa 35 -lib nucella_genome_april-families.fa -xsmall \
-gff nlap_genome_no_mito_no_bac.filtered.fasta &
