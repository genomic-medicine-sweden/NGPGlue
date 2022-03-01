#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;
use File::Basename qw(basename dirname);
use POSIX qw( strftime);
use File::Path qw( make_path );
use Getopt::Long;

##perl artic2fohm.pl --artic_outdir /gms-storage-gu/gothenburg/covid-temp/output-ssh  --metadata covidMetadataTemplateNoBOMNGP.json --prefix TEST-SSH --fastq_directory /gms-storage-gu/gothenburg/covid-temp/test-artic
#perl artic2fohm.pl --artic_outdir /gms-storage-gu/gothenburg/covid-temp/output-ssh  --metadata exampleData/covidMetadataTemplateNoBOMNGP.csv --prefix TEST-SSH --fastq_directory /gms-storage-gu/gothenburg/covid-temp/test-artic

## add example with files only in git-repo!!!
## perl artic2fohm.pl --artic_outdir exampleData/covid-temp/output-ssh  --metadata exampleData/covidMetadataTemplateNoBOMNGP.csv --prefix TEST-SSH --fastq_directory exampleData/covid-temp/test-artic


my $in_dir = "";
my $metadata_input ="";
my $Analysis_name = "";
my $fastqdir ="";
##GetOptions ('artic_outdir=s' => \$in_dir);
GetOptions ('artic_outdir=s' => \$in_dir,'fastq_directory=s' => \$fastqdir, 'prefix=s' => \$Analysis_name,'metadata=s' => \$metadata_input);
my $out_dir = $in_dir . "/UploadStage/" . $Analysis_name . "/";
##GetOptions ('uploadstage=s' => \$out_dir);

##GetOptions ('fastq_directory=s' => \$fastqdir);

##GetOptions ('prefix=s' => \$Analysis_name);

##GetOptions ('metadata=s' => \$metadata_json);

## Will change to read json directly later - now converts json to csv and reads that csv
my $metadata_csv = "";
if($metadata_input =~ /csv/){
    $metadata_csv = $metadata_input;
    print "HEJ\n";
}else{
    $metadata_csv = $metadata_input;
    $metadata_csv =~ s/json/csv/;
    system("perl ./../json2csv.pl $metadata_input $metadata_csv")
}
    
my $fasta_dir = $in_dir .  "/ncovIllumina_sequenceAnalysis_makeConsensus/";

my $out_dir_fohm = $out_dir . "/fohm";
if ( !-d $out_dir_fohm ) {
    make_path $out_dir_fohm or die "Failed to create path: $out_dir_fohm";
}

if ( !-d $out_dir_fohm . "/fastq" ) {
    make_path $out_dir_fohm . "/fastq" or die "Failed to create path: $out_dir_fohm" . "/fastq";
}


my $out_dir_gisaid = $out_dir . "/gisaid";
if ( !-d $out_dir_gisaid ) {
    make_path $out_dir_gisaid or die "Failed to create path: $out_dir_gisaid";
}


### ENA
my $out_dir_ENA = $out_dir . "/ENA";
if ( !-d $out_dir_ENA ) {
    make_path $out_dir_ENA or die "Failed to create path: $out_dir_ENA";
}
## /ENA
########
#######


my $SCRIPT_ROOT = dirname($0);

##my %config = read_config($SCRIPT_ROOT.'/fohm.config');
##my %Locations = read_config($SCRIPT_ROOT.'/LocationsClean.config');
##my %Adresses = read_config($SCRIPT_ROOT.'/AdressesClean.config');
my %Locations = read_config($SCRIPT_ROOT.'/config/LocationsClean.config');
my %Adresses = read_config($SCRIPT_ROOT.'/config/AdressesClean.config');

##my %id_conversion_table = read_conversion_table($SCRIPT_ROOT.'/conversion.table');
##my %gisaid_ids = read_gisaid_ids($gisaid_log);
my %metadata = read_pat_metadata($metadata_csv);


##print $metadata{"midnight_barcode04"}{InternalLabId} . "\n";
##print $metadata{"midnight_barcode04"}{labcode} . "\n";
##print $metadata{"midnight_barcode04"}{LibID} . "\n";

##my $full_out_dir = $config{out_dir}.'/'.basename($in_dir);
##my $prefix = $full_out_dir.'/'.$config{region_code}."_".$config{lab_code};
##system("mkdir -p $full_out_dir");

##my @vcfs = glob "$in_dir/*.freebayes.vep.vcf";

# Get pangolin file
##my $pangolin_fn = "$in_dir/pangolin_all.csv";
## take "TEST-SSH" as arg or wildcard it??

##my $pangolin_fn = "$in_dir/AnalysisReport/TEST-SSH/analysisReport.tsv";
my $pangolin_fn = "$in_dir/AnalysisReport/" . $Analysis_name . "/analysisReport.tsv";
die "No pangolin output!" unless -e $pangolin_fn;
my %Pangolin_data = read_PipelineResults($pangolin_fn);

##print $Pangolin_data{"midnight_barcode04"}{lineage} . "\n";

my $date = strftime '%Y-%m-%d', localtime;
   



##opendir my $dir, $in_dir or die "Cannot open directory: $!"; 
##opendir my $dir, $fastqdir or die "Cannot open directory: $!"; 
##my @files = readdir $dir;
##closedir $dir;



## fix fohm


my $GlobRegion ="";
my $GlobLab = ""; 
foreach my $SampleID (keys % metadata){
    ##print $SampleID . ";" . $metadata{"midnight_barcode04"}{sminetLID} .  ";"  .  $metadata{$SampleID}{Lab_code}   .  "\n";
    my $fohm_prefix =  $out_dir_fohm . "/fastq/" .  $metadata{$SampleID}{Sminet_LID} .  "_"  . $metadata{$SampleID}{Region_code} . "_"  .  $metadata{$SampleID}{Lab_code}  ;
    my @filesR1 = glob( $fastqdir . '/' . $SampleID . "*" . "R1"  ."*" . "fastq.gz" );
    if(0+@filesR1>1){die "multiple files match ID $SampleID"};
    if(0+@filesR1<1){die "no fastq-files assocated with $SampleID"};
    my $fq1 = $filesR1[0];
    my @filesR2 = glob( $fastqdir . '/' . $SampleID . "*" . "R2"  ."*" . "fastq.gz" );
    if(0+@filesR2>1){die "multiple files match ID $SampleID"};
    if(0+@filesR2<1){die "no fastq-files assocated with $SampleID"};
    my $fq2 = $filesR2[0];
    ##print $fq1 . "\n";
    ##print $fq2 . "\n";
     system "ln -sf $fq1 ${fohm_prefix}_1.fastq.gz";
     system "ln -sf $fq2 ${fohm_prefix}_2.fastq.gz";    
    $GlobRegion = $metadata{$SampleID}{Region_code};
    $GlobLab = $metadata{$SampleID}{Lab_code};


} 

## gisaid - columns out of sync!!! FIX!!  DO NOT USE GISAID

my $GISAID_meta_file = $out_dir_gisaid .'/'. $GlobRegion  ."_". $GlobLab  ."_".$date."_GISAIDsubmission.csv" ;

my $GISAID_fasta_file = $out_dir_gisaid .'/'. $GlobRegion  ."_". $GlobLab  ."_".$date."_GISAIDsubmission.fasta" ;
## system("cat $fasta_dir/*fasta > $GISAID_fasta_file");

open(GISAID_fasta , ">" . $GISAID_fasta_file) ;

open(GISAID, ">". $GISAID_meta_file);
##print GISAID "submitter,fn,covv_virus_name,covv_type,covv_passage,covv_collection_date,covv_location,covv_add_location,covv_host,covv_gender,covv_patient_age,covv_patient_status,covv_seq_technology,covv_coverage,covv_orig_lab,covv_orig_lab_addr,covv_subm_lab,covv_subm_lab_addr,covv_subm_sample_id,covv_authors,covv_provider_sample_id,covv_specimen,covv_outbreak,covv_add_host_info,covv_last_vaccinated,covv_treatment,covv_assembly_method\n";
print GISAID "\"submitter\",\"fn\",\"covv_virus_name\",\"covv_type\",\"covv_passage\",\"covv_collection_date\",\"covv_location\",\"covv_add_location\",\"covv_host\",\"covv_add_host_info\",\"covv_sampling_strategy\",\"covv_gender\",\"covv_patient_age\",\"covv_patient_status\",\"covv_specimen\",\"covv_outbreak\",\"covv_last_vaccinated\",\"covv_treatment\",\"covv_seq_technology\",\"covv_assembly_method\",\"covv_coverage\",\"covv_orig_lab\",\"covv_orig_lab_addr\",\"covv_subm_lab\",\"covv_subm_lab_addr\",\"covv_subm_sample_id\",\"covv_authors\"\n";
## submitter	fn	covv_virus_name	covv_type	covv_passage	covv_collection_date	covv_location	covv_add_location	covv_host	*covv_add_host_info	*covv_sampling_strategy	covv_gender	covv_patient_age	covv_patient_status	*covv_specimen	*covv_outbreak	*covv_last_vaccinated	*covv_treatment	covv_seq_technology	*covv_assembly_method	covv_coverage	covv_orig_lab	covv_orig_lab_addr	covv_provider_sample_id	covv_subm_lab	covv_subm_lab_addr	*covv_subm_sample_id	covv_authors	covv_comment	comment_type					


## "covv_specimen": "field_missing_error", "covv_outbreak": "field_missing_error", "covv_add_host_info": "field_missing_error", "covv_provider_sample_id": "field_missing_error", "covv_last_vaccinated": "field_missing_error", "covv_treatment": "field_missing_error", "covv_assembly_method": "field_missing_error"
##   "covv_provider_sample_id", "covv_specimen", "covv_outbreak", "covv_add_host_info", "covv_last_vaccinated", "covv_treatment", "covv_assembly_method"

foreach my $SampleID (keys % metadata){
    ##print $SampleID . "\n";
    ##print $metadata{$SampleID}{Submitter}  . "\n";
    
    $metadata{$SampleID}{FullGisaidName} = "hCoV-19/Sweden/" . $Locations{ $metadata{$SampleID}{Lab_code} } . "-" .  $metadata{$SampleID}{Pseudo_ID} . "/" . substr( $metadata{$SampleID}{Collection_date} ,0, 4);
    
    my @fastafiles = glob( $fasta_dir . '/' . $SampleID . "*" . "*" . "consensus.fa" . "*" );
    if(0+@fastafiles>1){die "multiple files match ID $SampleID"};
    if(0+@fastafiles<1){die "no fasta-files assocated with $SampleID"};   
    print GISAID_fasta ">" . $metadata{$SampleID}{FullGisaidName} . "\n";
    open( FASTA, $fastafiles[0]) ;                # read and discard a line
    <FASTA>;
    while (<FASTA>) {       # loop over the other lines
	print GISAID_fasta  $_;
    }
    close(FASTA);

    print GISAID join("\",\"", ("\"". "marten.lindqvist",

                        ## basename($fasta_fn),
			## $metadata{$SampleID}{Pseudo_ID} . ".fasta",
			    $GISAID_fasta_file,
			"hCoV-19/Sweden/" . $Locations{ $metadata{$SampleID}{Lab_code} } . "-" .  $metadata{$SampleID}{Pseudo_ID} . "/" . substr( $metadata{$SampleID}{Collection_date} ,0, 4),
                         $metadata{$SampleID}{Type},
			 
			 $metadata{$SampleID}{Passage_details},##Passage details/history
			 $metadata{$SampleID}{Collection_date},
			 "Europe / Sweden",
			 "",
			 
			 $metadata{$SampleID}{Host},
				"",
				"",
			 $metadata{$SampleID}{Patient_sex},
			 $metadata{$SampleID}{Patient_age},
				$metadata{$SampleID}{Patient_status},
				"",
				"",
				"",
				"",
			 $metadata{$SampleID}{Sequencing_technology},
				"",
				"",
			 $Locations{ $metadata{$SampleID}{Region_code} }, ## convert
			 $Adresses{ $metadata{$SampleID}{Region_code} }, ## convert
			 $Locations{ $metadata{$SampleID}{Lab_code} }, ## convert according to table  $Locations{}
			 $Adresses{ $metadata{$SampleID}{Lab_code} }, ## convert adress   $Adresses{}
			 
			 $metadata{$SampleID}{Pseudo_ID},
		         ##$metadata{$SampleID}{Submitter},
			 
			    
		      )  ) . "\",\"" . $metadata{$SampleID}{Submitter} . "\"\n"  ; # Check all boxes




}
close GISAID;

close GISAID_fasta;

##20210809_134201_gisaid_submission_Orebro.fasta
##$metadata{$SampleID}{FullGisaidName}
##my $check = join '|', keys %metadata;
##And then you can do the substitution as:

##s/($check)/$regex{$1}/g;

##open(F, $GISAID_fasta_file);
##while (<F>) {
##    foreach my $SampleID (keys %metadata) {
##	print $SampleID . "\n";
##	print $metadata{$SampleID}{FullGisaidName} . "\n";
##	s/$SampleID/\Q$metadata{$SampleID}{FullGisaidName}\E/g;
##      }
##}
##close(F);



#                          date($collection_date),
#                          location($origin),
#                          "", # Additonal location (e.g. Cruise Ship, Convention, Live animal market)
# 		 $config{host},
#                          "", # Additional host information (e.g. Patient infected while traveling in...)
#                          gender($gender),
#                          age($age),
#                          patient_status(),
#                          specimen_source(),
#                          outbreak(),
#                          last_vaccinated(),
#                          treatment(),
# 		 $config{sequencing_technology}, # FIXME: Take as argument
# 		 $config{assembly_method},
#                          coverage($IN_DIR, $sample_id),
# 		 $config{originating_lab},
# 		 $config{originating_lab_address},
#                          "", # Sample ID given by the sample provider
# 		 $config{submitting_lab},
# 		 $config{submitting_lab_address},
#                          "", # Sample ID given by the submitting lab
#		 $config{authors})
##    ) . "\n" . );





### fohm komplettering NB : does not handle multiple centers in the same metadatafile - solve sync issue woth GISAID accessions

my $FohmKompletteringFile = $out_dir_fohm .'/'. $GlobRegion  ."_". $GlobLab  ."_".$date."_komplettering.csv" ;

open(CSV, ">" . $FohmKompletteringFile);
print CSV "provnummer,urvalskriterium,pangolin,GISAID_accession\n";
foreach my $SampleID (keys % metadata){
print CSV $metadata{$SampleID}{Sminet_LID} . "," . $metadata{$SampleID}{Selection_criterion} . "," . "" . "\n"; 

}
close CSV;

##

my $FohmPangolinFile =  $out_dir_fohm .'/'. $GlobRegion  ."_". $GlobLab  ."_".$date."_pangolin_classification_format3.txt";

open(CSV, ">". $FohmPangolinFile);
print CSV "taxon\tlineage\tconflict\tambiguity_score\tscorpio_call\tscorpio_support\tscorpio_conflict\tversion\tpangolin_version\tpangoLEARN_version\tpango_version\tstatus\tnote\n";
foreach my $SampleID (keys % metadata){
    ##print $SampleID . "\n";
    print CSV $metadata{$SampleID}{Sminet_LID} . "\t" . $Pangolin_data{$SampleID}{lineage}  . "\t" . $Pangolin_data{$SampleID}{conflict} . "\t" . $Pangolin_data{$SampleID}{ambiguity_score} . "\t". $Pangolin_data{$SampleID}{scorpio_call} . "\t". $Pangolin_data{$SampleID}{scorpio_support} . "\t". $Pangolin_data{$SampleID}{scorpio_conflict} . "\t". $Pangolin_data{$SampleID}{version} . "\t". $Pangolin_data{$SampleID}{pangolin_version} . "\t". $Pangolin_data{$SampleID}{pangoLEARN_version} . "\t". $Pangolin_data{$SampleID}{pango_version} . "\t". $Pangolin_data{$SampleID}{status} . "\t" . $Pangolin_data{$SampleID}{note} . "\n";
    ##taxon lineage conflict ambiguity_score scorpio_call scorpio_support scorpio_conflict version pangolin_version pangoLEARN_version pango_ver pango_version status note
}
close CSV;


#####
### ENA




##### /ENA
##########






##foreach my $vcf_fn ( @vcfs ) {
#     my ($sample_id) = (split /\./, basename($vcf_fn))[0];
#     next if $sample_id eq "NTC" or $sample_id =~ "No_Sample" or $sample_id eq "No" or $sample_id =~ /NegativeControl/;
#     ##my $mlu_id = $metadata{$sample_id}->{SID};
#     my $mlu_id = $metadata{$sample_id}->{InternalLabId};
    
#     # Parse QC data
#     my $qc_data;
#     if( -e "$in_dir/$sample_id.qc.csv") {
# 	$qc_data = read_qc_data("$in_dir/$sample_id.qc.csv");
#     } else {
# 	die "QC data not found for $sample_id!\n";
#     }

#     # Check if QC passed
#     next if $qc_data->{pct_N_bases} > 5;

#     ##print CSV "$mlu_id,".($metadata{$sample_id}->{Urval} or "Information saknas").",".$gisaid_ids{$id_conversion_table{$sample_id}}."\n";
#     print CSV "$mlu_id,".($metadata{$sample_id}->{Selection_criterion} or "Information saknas").",". "GISAID!!!" ."\n";
    
#     my $fa_fn = "$in_dir/$sample_id.consensus.fa";
#     die "No fasta for $sample_id" unless -e $fa_fn;

#     my $fq1 = "$in_dir/${sample_id}_subsample_R1_001.fastq.gz";
#     my $fq2 = "$in_dir/${sample_id}_subsample_R2_001.fastq.gz";
#     die "Fastq files missing for $sample_id!" if( ! -e "$in_dir/${sample_id}_R1_001.fastq.gz" or ! -e "$in_dir/${sample_id}_R2_001.fastq.gz" );

#     copy_and_fix_fasta($fa_fn, "${prefix}_${mlu_id}.consensus.fasta", "${prefix}_${mlu_id}");
#     system "ln -sf $vcf_fn ${prefix}_${mlu_id}.vcf";
#     system "ln -sf $fq1 ${prefix}_${mlu_id}_1.fastq.gz";
#     system "ln -sf $fq2 ${prefix}_${mlu_id}_2.fastq.gz";
    
# }

##reformat_pangolin($pangolin_fn, "${prefix}_${date}_pangolin_classification_".($config{pangolin_format} == 2 ? "format2" : "").".txt", \%metadata);



##### Snippet for

##lftp -c "set sftp:connect-program 'ssh -a -x -i ~/.ssh/id_rsa_gensam' ;open sftp://se120:@gensam-sftp.folkhalsomyndigheten.se/  ; cd till-fohm ;lcd /data/bnf/sarscov2/results/fohm/210911_NB501697_0270_AH33MWAFX3/ ; mirror -L -R -P 5 --ignore-time"
##lftp -c 
my $lftp_command = "set sftp:connect-program 'ssh -a -x -i ~/.ssh/id_rsa_gensam' ;open sftp://" .  $GlobLab . ":\@gensam-sftp.folkhalsomyndigheten.se/  ; cd till-fohm ;lcd " . $out_dir_fohm . "/fastq" . " ; mirror -L -R -P 5 --ignore-time";
##print $lftp_command . "\n";

print "\n\nCheck this command and run it to upload to FOHM:\n\n";
print "lftp -c \"" . $lftp_command . "\"\n\n" ;
my $FohmKompletteringFileBase = basename($FohmKompletteringFile);
print "Check this command and run it to send additional info to FOHM by mail:\n\n";
print "echo \"Kompletterande data\" | mailx -S smtp=smtp.gu.se -s $FohmKompletteringFileBase -a $FohmKompletteringFile -v bokelund\@gmail.com \n\n";
##
## $FohmKompletteringFile

print "Check this command and run it to upload results to GISAID \n";
print "./gisaid_uploader CoV upload --fasta $GISAID_fasta_file --csv   $GISAID_meta_file --failedout ". $GISAID_meta_file . "_failed_metadata.csv\n\n";



#############################################################################################
#############################################################################################
#############################################################################################

sub copy_and_fix_fasta {
    my ($orig_file, $new_file, $new_id) = @_;
    open(my $orig_fh, $orig_file) or die "cannot read: $orig_file\n";
    open(my $new_fh, '>'.$new_file) or die "cannot create file: $new_file\n";
    while(<$orig_fh>) {
	if( /^>/ ) {
	    print $new_fh ">$new_id\n";
	}
	else {
	    print $new_fh $_;
	}
    }
    close $new_fh;
    close $orig_fh;
}

sub reformat_pangolin {
    my ($in_fn, $out_fn, $metadata) = @_;
    open(my $in, $in_fn);
    open(my $out, ">".$out_fn);
    my $header = <$in>;
    print $out $header;
    while(my $line = <$in>) {
	my ($old_id) = ($line =~ /^.*?_(.*?)\./);
	my $new_id;
	if($metadata->{$old_id}->{SID}) {
	    my $new_id =  $metadata->{$old_id}->{SID};
	} else {
	    print STDERR "No SID (MLU ID) found for $old_id! Removing from pangolin file\n";
	    next;
	}
    
	$line =~ s/^.*?_(.*?)\..*?,/$new_id,/; # Remove the stuff surrounding the ID.
	print $out $line;
    }
    close $in;
    close $out;
}
    
sub read_qc_data{
    my $fn = shift;
    my @data = read_csv($fn, ',');
    return $data[0];

}

sub read_csv {
    my $fn = shift;
    my $sep = shift;
    open (my $fh, $fn);
    chomp(my $header = <$fh>);
    $header =~ s/\r//;
    my @header = split /$sep/, $header;
    
    my @data;
    while(<$fh>) {
	chomp;
	s/\r//;
	my @a = split /$sep/;
	my %entry;
	for my $i (0..$#header) {
	    $entry{$header[$i]} = $a[$i];
	}
	push @data, \%entry;
    }
    return @data;
    
}

sub read_config {
    my $fn = shift;
    open(my $fh, $fn) or die;
    my %config;
    while(<$fh>) {
	chomp;
	my ($key, $value) = split /=/;
	$config{$key} = $value;
    }
    close $fh;
    return %config;
}

sub read_conversion_table {
    my $fn = shift;
    open(my $fh, $fn);
    my %table;
    while(<$fh>) {
	chomp;
	my ($pseudo, $real) = split /\t/;
	$table{$real} = $pseudo;
    }
    return %table;
}

sub read_gisaid_ids {
    my $fn = shift;
    open(my $fh, $fn);
    my %table;
    while(<$fh>) {
	next if /^submissions /;
	chomp;
	my ($name, $gisaid) = split '; ';
	my @a = split /\//, $name;
	my $pseudo_id = $a[2];
	$pseudo_id =~ /(0)*(\d+)$/;
	my $pseudo_num = $2;
	$table{$pseudo_num} = $gisaid;
    }
    return %table;
}

## sed $'1s/\xef\xbb\xbf//' < FohmAndGisaidMinimumExamplelim3.csv > FohmAndGisaidMinimumExamplelim3NoBom.csv

sub read_pat_metadata {
    my $fn = shift;
    ##$fn =~ s/^\x{FEFF}//;
    $fn =~ s/\N{U+FEFF}//;
    my @csv = read_csv("iconv -f iso-8859-1 -t UTF-8 '$fn'|", ";");
    my %csv;
    foreach my $entry (@csv) {
	##$csv{$entry->{Labbnummer}} = $entry;
	##print $entry->{InternalLabId} . "\n";
##	print "$_\n" for keys $entry;
	$csv{$entry->{Internal_lab_ID}} = $entry;
    }
    return %csv;
}

sub read_PipelineResults {
    my $fn = shift;
    ##$fn =~ s/^\x{FEFF}//;
    $fn =~ s/\N{U+FEFF}//;
    my @tsv = read_csv("iconv -f iso-8859-1 -t UTF-8 '$fn'|", "\t");
    my %PipeRes;
    foreach my $entry (@tsv) {
	##$csv{$entry->{Labbnummer}} = $entry;
        ##print $entry->{taxon} . "\n";
	## Change to 'sample name' instead of taxon
	my $FixedID = $entry->{taxon};
	$FixedID =~ s/\/.*//;
	$FixedID =~ s/Consensus_//s;
	$FixedID =~ s/.primertrimmed.consensus.*//s;
	##print $FixedID  . "\n";
##      print "$_\n" for keys $entry;
        $PipeRes{$FixedID} = $entry;
    }
    return %PipeRes;
}
