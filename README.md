# The Atlantic dog whelk (_Nucella lapillus_) genome

This Whole Genome Shotgun project was generated with ONT long reads and RNASeq data. The genome has been deposited at DDBJ/ ENA/GenBank under the accession JBNHDL000000000. 
Data generated in this study are available under NCBI BioProject PRJNA1238877. 
 
The DNA extraction protocol and code used are housed in this repository. 

## Sample information 
An individual was collected in Nahant, MA, in 2024 and is pictured below. The foot tissue was used for DNA extraction and isolation. The extraction protocol can be found in the [extraction file](https://github.com/meghanclownfish/Nucella-lapillus-genome/tree/main/1_extraction)  

<img src="https://github.com/meghanclownfish/snail-DNA-extractions/assets/78237587/2455c8bc-c58e-4127-9c2b-5f94616deefb" width="200" height="200">


## Library prep and sequencing 

Libraries were prepped with the ONT ligation sequencing kit and NEB companion module. Sequencing was done on a PromithION. Six flow cells in total were used to generate 103,553,219,099 bp raw data.

<img src="https://github.com/user-attachments/assets/7ef08c7c-550f-4c68-bed8-1c2788dff560" width="500" height="200">



## Assembly and annotation

Briefly, we assembled the genome using all reads of 2kb in length or greater with Hifiasm. Blobtools was used to visually assess the assembly and filter contigs. RepeatModeler and RepeatMasker identified and soft-masked repetitive regions in the genome. RNASeq data was mapped to the soft-masked genome with HISAT2. This information, along with a custom protein database, was supplied as evidence for Braker3. TSEBRA was used to merge Braker outputs. Functional annotation was carried out with InterProScan and Funannotate. 

Assembly commands can be found in [2_assembly](https://github.com/meghanclownfish/Nucella-lapillus-genome/tree/main/2_assembly) \
Annotation commands are in [3_annotation](https://github.com/meghanclownfish/Nucella-lapillus-genome/tree/main/3_annotation)\
Functional annotation commands are located in [4_functional-annotation](https://github.com/meghanclownfish/Nucella-lapillus-genome/tree/main/4_functional-annotation)

##
All pictures in this repository were taken by Meghan Ford 
