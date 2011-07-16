# Implements the Google search class for Bio-Wet

# BIO-WET is a Bioinformatics Web Service Evaluation Toolkit
# Google search for BIO-WET

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

package Google_AJAX;

use strict;
use warnings;
use 5.010;
use Google::Search;
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


sub GOOGLEsearch {
	
	my $this = shift;
	
	my $keywords = $this->{ _keywords};
	
	my $timestamp = $this->{ _timestamp};
		
	my @searches = split(/\s*,\s*/,$keywords);
	

for my $query (@searches) {

my $max = 63;
    
    my $i=1;
    my $search = Google::Search->web( query => $query );
    
    if (! defined ($search->first)) {
    	$this->{ _dbHandle}->do("insert into Google_URLs (Keywords, TimeStamp, Rank, Url, Url_Domain) values ('$query', $timestamp, 0, '', '')");       
        $this->{ _dbHandle}->commit(); next;
    	}
    else {    
	    while ( my $result = $search->next ) {
	        ## say $result->rank, " ", $result->uri;
	        my $rank = $result->rank+1;
	        my $url = $result->uri;
	        $url =~ s/^.*\/\///;
	        my @url = split (/\//,$url);
	        my $domain = $url[0];       
	        
			$this->{ _dbHandle}->do("insert into Google_URLs (Keywords, TimeStamp, Rank, Url, Url_Domain) values ('$query', $timestamp, '$rank', '$url', '$domain')");       
	        $this->{ _dbHandle}->commit();
	        $i++; if ($i > $max) { last };
	    }
	
	sleep rand (15); 
	    }
    }
$this->{ _dbHandle}->disconnect();
}

1; 