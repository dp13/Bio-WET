#!/usr/bin/perl

use Google_AJAX;
use Pubmed_search;
use POSIX;

##########################
## Timestamp & Database ##
##########################

my $db="/home/dietmar/FHbioinformatik/Semester2/Web_service/demo.sqlite";
my $timestamp = time;

##########################
## Usage of Google_AJAX ##
##########################

my $google_keywords="skdkfjoiejekwg, \"DNA Sequencing\"";
my $google_object = Google_AJAX->new($db,$google_keywords,$timestamp);
$google_object->GOOGLEsearch;


############################
## Usage of Pubmed_search ##
############################

my $pubmed_keywords="frtgr , MultiExperiment Viewer";
my $pubmed_object = Pubmed_search->new($db,$pubmed_keywords,$timestamp);
$pubmed_object->PUBMEDsearch;