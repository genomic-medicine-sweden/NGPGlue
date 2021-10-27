Perl ExternalUploader.pl \
    --prefix "test_illumina"     \
    --fastq_directory .github/data/fastqs/    \
    --artic_outdir illumina_test
    --metadata covidMetadataTemplate.json

Files will be written to the same directory where artic writes its file under UploadStage/*prefix*/[fohm,gisaid]

TODO
* read logfile from artic to automatically parse parameters
* improve json import
