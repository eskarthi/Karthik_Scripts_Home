#!/home/perl-5.8.0/bin/perl

###############################################################################
# Description :This script helps to do recon between sod vs eod 
#             1)Will parse the SPEAR_POSITIONS.REC =>position.txt & eodPositionFile
#             2)Store it in hash.
#             3)Match the value of key .    
#
# author :ekarthik
# date   :2010/01/13
################################################################################

use strict;
use POSIX;

my $qry_format=$ARGV[0];

sub getYYYYMMDD() {
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
  $mon++;
  if($mday < 10) { $mday = "0".$mday; }
  if($mon  < 10) { $mon  = "0".$mon; }
  return  (1900+$year)."$mon"."$mday";
}


my $yyyymmdd=&getYYYYMMDD;
my $sod_fileName ="";
my $eod_fileName = "";

#my $sod_fileName = "/home/svcegctp/prod/bin/scripts/recon/data/20100131/position.txt";
#my $eod_fileName = "/home/svcegctp/prod/bin/scripts/recon/data/20100131/eodPositionFile.csv";


if ( $qry_format eq "all" )
{
$sod_fileName = "/home/svcegctp/prod/bin/scripts/recon/data/$yyyymmdd/position.txt";
$eod_fileName = "/home/svcegctp/prod/bin/scripts/recon/data/$yyyymmdd/eodPositionFile.csv";

}

if ( $qry_format eq "getco" )
{
 $sod_fileName = "/home/svcegctp/prod/bin/scripts/recon/data/ClientG_$yyyymmdd/position.txt";
 $eod_fileName = "/home/svcegctp/prod/bin/scripts/recon/data/ClientG_$yyyymmdd/eodPositionFile.csv";
}





my %sod_fileHash=();
my %eod_fileHash=();

open(SODLINE, "<$sod_fileName") or die "Unable to open file: $sod_fileName";

my $line=0;

while(my $series = <SODLINE>)
{
  $line++;

  #skip the header and description.
  if($line > 1)
  {
    chomp($series);
    my @rec = split(/,/, $series);  # split into .,. seperated fragments

    # Parse and print each line and store it in a array .
    # print "@rec"."\n";
    #print $rec[0].$rec[1]."=>".$rec[2] ."\n";
    if (exists ($sod_fileHash {"$rec[0].$rec[1]"}))
         {
         print "duplicate sod position values found :".$rec[0].",".$rec[1]."=>".$rec[2] ."\n";
         }
     else{
         $sod_fileHash { "$rec[0].$rec[1]" }  = { "$rec[0].$rec[1]" => $rec[2] };
         }
  }
}

open(EODLINE, "<$eod_fileName") or die "Unable to open file: $eod_fileName";

my $eodline=0;

while(my $series = <EODLINE>)
{
  $eodline++;

  #skip the header and description.
  if($eodline > 1)
  {
    chomp($series);
    my @rec = split(/,/, $series);  # split into .,. seperated fragments

    # Parse and print each line and store it in a array .
    # print "@rec"."\n";
    # print $rec[0].$rec[1]."=>".$rec[2] ."\n";
    if (exists ($eod_fileHash {"$rec[0].$rec[1]"}))
	 {
	 print "\n"."duplicate eod position values found :".$rec[0].",".$rec[1]."=>".$rec[2] ."\n"; 
         }
     else{
	    $eod_fileHash { "$rec[0].$rec[1]" }  = { "$rec[0].$rec[1]" => "$rec[2]" };
	 }
  }
}

# Check the values exists in sod positions 

my $found=0;
my @notMatchingsod=();
      
        print "\n\n"."For the following records SOD quantity is not matching with EOD \n"; 
        print "\n\n"."ACCOUNTID.RIC,SOD,EOD \n";      
       
        foreach my $eodkey (sort (keys (%eod_fileHash) )) { 

                my $eodPosvalue =$eod_fileHash {"$eodkey"} ->{"$eodkey"};

                if (exists ($sod_fileHash {$eodkey} )) {

                my $sodPosvalue =$sod_fileHash {"$eodkey"} ->{"$eodkey"};
            
	       if ($eodPosvalue <=> $sodPosvalue)
        	 { 
                    $found ++;
	            print $eodkey.",".$sodPosvalue.",".$eodPosvalue."\n";
        	   # print "SOD -Positions:".$eodkey.",".$sodPosvalue."\n";
	         }

	        } # End of if exists
                else
                {
                if ( $eodPosvalue != 0 ) { 
                push (@notMatchingsod, $eodkey.",".$eodPosvalue."\n");
                }
                }
        } # end of eodFile hash

print "\n\n"."Number of records SOD quantity is not matching with EOD  : $found \n";
print "\n".">>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< \n";


# obtain size of array  
my $count = @notMatchingsod;
  
	print "\n"."No matching data found for the following SOD positions: \n";
        print "\n\n"."ACCOUNTID.RIC,SOD,EOD \n"; 
        print "@notMatchingsod";
        print "\n"."Number of records not matching with SOD: ".$count."\n"
