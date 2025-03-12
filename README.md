# The Atlantic dog whelk (_Nucella lapillus_) genome

A reference genome was assembled using ONT long reads. 

Thr project can be found at NCBI XXX. 

## Sample information 
An individual was collected in Nahant, MA, in 2024 and is pictured below. The foot tissue was used for DNA extraction and isolation. The protocol can be found in the [extraction file](https://github.com/meghanclownfish/Nucella-lapillus-genome/tree/6ee388e96acaa53040e682a8f8f69fad87a258cc/extraction)  

<img src="https://github.com/meghanclownfish/snail-DNA-extractions/assets/78237587/2455c8bc-c58e-4127-9c2b-5f94616deefb" width="200" height="200">

## Library prep and sequencing 

Libraries were prepped with the ONT ligation sequencing kit and NEB companion module. Sequencing was done on a PromithION. Six flow cells in total were used to generate 112,563,429,491 bp raw data.

<img src="https://github.com/user-attachments/assets/7ef08c7c-550f-4c68-bed8-1c2788dff560" width="500" height="200">



## Assembly and annotation

Briefly, we assembled the genome using all reads of 2kb in length or greater with Hifiasm. Blobtools was used to visually assess the assembly and filter contigs. RepeatModeler and RepeatMasker identified and soft-masked repetitive regions in the genome. RNASeq data was mapped to the soft-masked genome with HISAT2. This information, along with a custom protein database, was supplied as evidence for Braker3. TSEBRA was used to merge Braker outputs. Functional annotation was carried out with EnTAP.  
