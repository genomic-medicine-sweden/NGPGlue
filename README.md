# NGPGlue Script Index
Small scripts and other similar NGP solutions

## artic2external

Invocation
```
perl artic2external.pl 
--prefix "test_illumina"
--fastq_directory .github/data/fastqs/
--artic_outdir illumina_test --metadata covidMetadataTemplate.[json|csv]
```

* Flags prefix, fastq_directory and artic_outdir should match that of GMS-Artic invocation.

* Metadata can be generated using the GMS-uploader. 

* Metadata can be provided as either json or csv, determined by the file-suffix.

* Output is written to same output folder as gms-artic, e.g. `{artic_outdir}/UploadStage/{prefix}/[fohm,gisaid]`

* Metadata format is defined by the template at: https://kise.sharepoint.com/❌/r/teams/GRP_GenomicMedicineSweden/Delade%20dokument/AU%20Mikrobiologi/Bioinformatik/Pipeline%20SARS-CoV-2/covidMetadataTemplate.csv?d=we199e2b9e0bc4a068dbd56e989a4d90b&csf=1&web=1&e=gHdedC 

* Output is written to same output folder as gms-artic, e.g. `{artic_outdir}/UploadStage/{prefix}/[fohm,gisaid]`

* Output FoHM directory has subdirectories with fastq-files using the name suggested by FOHM (symlinked to the original files), a file with extra information `*komplettering.csv` and a file with pangolin-classification `*classification_format3.txt`. The files have lab-id, region-id and date as prefixes.

* Output GISAID directory has a metadata file `GISAIDsubmission.csv`, and a fasta-file `GISAIDsubmission.fasta` containing all consensus-sequences connected to the metadata.  The files have lab-id, region-id and date as prefixes.

## split_gms-artic.sh
This script splits a folder of fastqs into multiple smaller folders. 
This is a quick fix to avoid the concurrency issue of starting GMC-Artic on several thousand samples located in a single directory.

### Limitations
The script will currently only work for the illumina workflow. The nanopore workflow requires a different input.

## json2csv.pl
Simple json to csv conversion script
