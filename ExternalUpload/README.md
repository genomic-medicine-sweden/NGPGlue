Perl ExternalUploader.pl \
    --prefix "test_illumina"     \
    --fastq_directory .github/data/fastqs/    \
    --artic_outdir illumina_test
    --metadata covidMetadataTemplate.[json|csv]
    
Apart from the addition of --metadata the input to ExternalUploader should be the same as the input to the artic. Metadata should have the same format as provided by the template at: https://kise.sharepoint.com/:x:/r/teams/GRP_GenomicMedicineSweden/Delade%20dokument/AU%20Mikrobiologi/Bioinformatik/Pipeline%20SARS-CoV-2/covidMetadataTemplate.csv?d=we199e2b9e0bc4a068dbd56e989a4d90b&csf=1&web=1&e=gHdedC Preferably this is created using the GMS-uploader in this git-project. metadata can be provided as both json or csv and this is determined on the file-suffix.

Files will be written to the same directory where artic writes its file under {artic_outdir}/UploadStage/{prefix}/[fohm,gisaid]

When executed the fohm directory will have directory with fastq-files using the name suggested by FOHM (symlinked to the original files), a file with extra information *komplettering.csv and a file with pangolin-classification (*classification_format3.txt). The files have lab-id, region-id and date as prefices.

When executed the gisaid directory will contain a metadata file (*_GISAIDsubmission.csv) and a fasta-file (*_GISAIDsubmission.fasta) containing all consensus-sequences connected to the metadata. Prefices are the same as for fohm.

TODO
* read logfile from artic to automatically parse parameters
* improve json import
