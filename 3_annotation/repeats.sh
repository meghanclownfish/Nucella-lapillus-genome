# RepeatModeler (version = 2.0.6)
singularity pull dfam-tetools-latest.sif docker://dfam/tetools:latest

# activate conda env with singularity
conda activate repeatmodeler_env
singularity run ../dfam-tetools-latest.sif

BuildDatabase -name nucella_genome hifi_2kb_decontaminated.fa 

# start an instance 
singularity instance start ../dfam-tetools-latest.sif run_rm

# run modeler and masker
nohup singularity exec instance://run_rm RepeatModeler -LTRStruct -database nucella_genome -threads 35 &
nohup singularity exec instance://run_rm RepeatMasker -pa 35 -lib ../nucella_genome-families.fa -xsmall -gff ../hifi_2kb_decontaminated.fa &

