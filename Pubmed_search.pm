# Implements the Pubmed search class for Bio-Wet

# BIO-WET is a Bioinformatics Web Service Evaluation Toolkit
# Pubmed search for BIO-WET

# ***********************************************************************
# *  Copyright notice
# *
# *  Copyright 2010-2011 Dietmar Pils <Dietmar@Pils.name>
# *  All rights reserved
# *
# *  This program is free software: you can redistribute it and/or modify
# *  it under the terms of the GNU General Public License as published by
# *  the Free Software Foundation, either version 3 of the License, or
# *  (at your option) any later version.
# *
# *  This program is distributed in the hope that it will be useful,
# *  but WITHOUT ANY WARRANTY; without even the implied warranty of
# *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# *  GNU General Public License for more details.
# *
# *  You should have received a copy of the GNU General Public License
# *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
# *
# *  This copyright notice MUST APPEAR in all copies of the script!
# ***********************************************************************


package Pubmed_search;

use strict;
use warnings;
use 5.010;
use DBI;

sub new { 
	my $class = shift;
		
    my $this =
     {
         
         _dbName => shift,
         _keywords => shift,
         _timestamp => shift,
     };

        my $dn = $this->{_dbName};
        
        my $dbargs = {AutoCommit => 0,
             			PrintError => 1};
     	
     	my $dbh = DBI->connect("dbi:SQLite:dbname=$dn","","",$dbargs);
    	$this->{ _dbHandle} = $dbh;
	
		if ($this->{ _dbHandle}->err()) { die "$DBI::errstr\n"; }

     	bless $this, $class;
     	return $this;
}


sub PUBMEDsearch {
	
	my $this = shift;
	
	my $keywords = $this->{ _keywords};
	
	my $timestamp = $this->{ _timestamp};
		
	my @searches = split(/\s*,\s*/,$keywords);
	
for my $query (@searches) {

my $max = 100;
    
    my $query_name = $query;
    $query_name =~ s/\s/_/g;
        
    `./pubcrawler.pl -out dummy.html -l ${query_name}.log -s 'pubmed#$query_name#$query [ALL]'`;
        
   open (FH, "${query_name}.log") or die $!;
   
   my $j=0;
   my ($noofhits, $hits);
    
   while (my $line = <FH>) {
   		if ($j == 1) {
   			$hits = $line; $j = 0; next; 	
   		}  
   		elsif ($line =~ /^0 hits/ ) {
   			$hits="" ; last;
   		}
   		elsif ($line =~ /hits/ ) {
   			$noofhits = $line ;
   			$noofhits =~ s/\D//g ; last;
   		}
   		elsif ($line =~ /result of query is/ ) {
   			$j = 1; next }
   		
   		}
   
		    if ($hits eq "") {
		    	$this->{ _dbHandle}->do("insert into Pubmed_results (Keywords, TimeStamp, No_of_hits, Rank, PMID) values ('$query', $timestamp, 0, '', '')");       
		    	$this->{ _dbHandle}->commit();	
		    }
		    
		    else { my @hits = split(/\s+/,$hits);
			
			my $i=1;
			PMID: for my $PMID (@hits) {
		    
		    	## say $PMID, ", rank ", $i, " by " , $noofhits, " hits.";
		    	
				$this->{ _dbHandle}->do("insert into Pubmed_results (Keywords, TimeStamp, No_of_hits, Rank, PMID) values ('$query', $timestamp, '$noofhits', '$i', '$PMID')");       
		        $this->{ _dbHandle}->commit();
		        $i++; if ($i > $max) { last PMID };
			}	 
	
	unlink "${query_name}.log" or say "File: '${query_name}.log' not deleted!";
	unlink "dummy.html" or say "'dummy.html' not deleted!"; 
	
	close(FH);
			} 
	}

$this->{ _dbHandle}->disconnect();

}

1; 