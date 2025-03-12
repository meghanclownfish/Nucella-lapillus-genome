#entap with uniprot_sprot an refseq_invertebrarte

singularity run ../entap.sif

#configure
EnTAP --config --run-ini entap_run.params --entap-ini entap_config.ini -t 5

#update all paths in parms and ini with given info before moving on, for eggNog SQL database, include path but not file (EnTap will not understand if you give file) 

#run entap
EnTAP --run -i iso_filt_aug_enforcement.faa -t 35
