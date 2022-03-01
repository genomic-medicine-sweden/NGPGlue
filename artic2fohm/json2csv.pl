#!/usr/bin/perl
##use local::lib;
use warnings;
use strict;

##perl Makefile.PL PREFIX=/Users/melt/Dropbox/ORU/GMS/SarsCov2-pipeline/sarscov2/PerlLibs/
##make
##make test
##make install
##export PERL5LIB=/Users/melt/Dropbox/ORU/GMS/SarsCov2-pipeline/sarscov2/PerlLibs/lib/perl5/site_perl/

use JSON;
use Text::CSV_XS;
use File::Slurp;


my $str = read_file('covidMetadataTemplate.json');

my $json = '[ {
                "name" : "Lee calls",
                "empid" : "1289328",
                "desc_id" : "descl23423..23431"
              },
              {
                "name" : "Lee calls",
                "empid" : "23431223",
                "desc_id" : "descl23423..234324"
              } ]';


##my $struct = decode_json($json);
my $struct = decode_json($str);

##my %hash = decode_json($json);



##print $struct . "\n" ;

my $csv = 'Text::CSV_XS'->new({ binary => 1, eol => "\n",sep_char=> ";" });
open my $OUT, '>:encoding(UTF-8)', 'output.csv' or die $!;
print $OUT  "Internal_lab_ID;Sminet_LID;Pseudo_ID;Region_code;Lab_code;Selection_criterion;GISAID_acc;Submitter;Type;Passage_details;Collection_date;Host;Patient_sex;Patient_age;Patient_status;Sequencing_technology;Library_method;Lane;Fastq1;Fastq2;Fast5;Seq_path;Comment\n";
##$csv->print($OUT, [ @$_{qw{name  empid desc_id }} ]) for @$struct;
##$csv->print($OUT, [ @$_{qw{Internal_lab_ID Sminet_LID Pseudo_ID }} ]) for @$struct;
$csv->print($OUT, [ @$_{qw{ Internal_lab_ID Sminet_LID Pseudo_ID Region_code Lab_code Selection_criterion GISAID_acc Submitter Type Passage_details Collection_date Host Patient_sex Patient_age Patient_status Sequencing_technology Library_method Lane Fastq1 Fastq2 Fast5 Seq_path Comment  }} ]) for @$struct;
close $OUT or die $!;


##Internal_lab_ID;Sminet_LID;Pseudo_ID;Region_code;Lab_code;Selection_criterion;GISAID_acc;Submitter;Type;Passage_details;Collection_date;Host;Patient_sex;Patient_age;Patient_status;Sequencing_technology;Library_method;Lane;Fastq1;Fastq2;Fast5;Seq_path;Comment
