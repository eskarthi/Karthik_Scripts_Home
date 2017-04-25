#! /usr/bin/perl

use Switch;

#######################################################################################################
# Author: Erode Shanmugam Karthikeyan
# Created on: feb 03, 2010

# Script will read session file containing data and query the mysql and extract the record
## 

#######################################################################################################

my $julian_date=$ARGV[0];
my $checkhost=$ARGV[1];
my $qry_format=$ARGV[2];

# ASIA PROD
#=======================
#my @AS_HOSTS=("tkodclxeqprd030", "tkodclxeqprd099");
#my $AS_DB_USER="root";
#my $AS_DB_PSWD="";
#my $AS_DB_NAME="ws_data";

# ASIA STAGE
#=======================
#my @AS_HOSTS=("tkodclxeqcat094", "tkodclxeqcat100");
#my @AS_HOSTS=("tkodclxeqcat100");

my @AS_HOSTS=("tklxeqprd099", "tklxeqprd092");
my $AS_DB_USER="root";
my $AS_DB_PSWD="";
my $AS_DB_NAME="ws_data";

my $LOG_DIR="/local/0/appslog/cstprod/recon";
my $inputFile="";

my $SQL_PATH ="/home/cstprod/mysql/bin/mysql";


my $TARGET_LOCATION="";
my $QUERY="";

my $host="";
my $SQL ="";
my %hhOrders =();
#####################################################################################################
##Main script calling subroutines
my @sessionid=();
my $qrystring="";


switch  ($checkhost) {

                 case "99"
                        {
                         $host="tklxeqprd099";
			 $inputFile="/home/aseqpmgp/CCT/SPS/prod/bin/recon/QPSClientsTradeReport.txt";
                         print "Host $host ..\n" ;
                         break;
                        }

                 case "92"
                        {
                         $host="tklxeqprd092";
			 $inputFile="/home/aseqpmgp/CCT/SPS/prod/bin/recon/QPSClientsTradeReport.txt";
                         print "Host $host ..\n" ;
                         break;
                        }


                 case "04"
                        {
                         $host="tkodclxeqcstprd004";
			 $inputFile="/home/aseqpmgp/CCT/SPS/prod/bin/recon/QPSClientGTradeReport.txt";
                         print "Host $host , FileName :$inputFile..\n" ;

                         break;
                        }

		 case "odc099"
                        {
                         $host="tkodclxeqprd099";
                         $inputFile="/home/aseqpmgp/CCT/SPS/prod/bin/recon/QPSClientTTradeReport.txt";
                         print "SPBGW Host $host ..\n" ;
                         break;
                        }
                 else
                        {
                          print "\n please provide host to search \n";
                        }
        }



&parseFile($inputFile);

my $SESSION=substr($qrystring ,0,length($qrystring)-1);


switch ($qry_format) {

                case "search" 
                        { print "record count search ..\n" ;
                         $TARGET_LOCATION="$LOG_DIR/$host"."_recon_count" ;
                         $QUERY="select count(*) from TRADES o where o.SESSION_ID in ( $SESSION ) and o.JULIAN_DATE = '$julian_date' into outfile '$TARGET_LOCATION' ;";
                         break;
			}

                case "extract" 
	             {  print "values extract ...\n";
			$TARGET_LOCATION="$LOG_DIR/$host"."_ClientsReconDetails" ;
               		$QUERY="select o.CLIENT_ACRONYM , count(*) from TRADES o where o.SESSION_ID in ( $SESSION ) and o.JULIAN_DATE = '$julian_date'  group by o.CLIENT_ACRONYM into outfile '$TARGET_LOCATION' fields terminated by ',' ;" ;
			
                        break;
		     }	
                case "qty_search" 
                       {  print "count qty_search .. .\n" ;
			 $TARGET_LOCATION="$LOG_DIR/$host"."_qty_count" ;
               		 $QUERY="select sum(QUANTITY) from TRADES o where o.SESSION_ID in ( $SESSION ) and o.JULIAN_DATE = '$julian_date' into outfile '$TARGET_LOCATION' ;";

                         break;
			}
                case "qty_extract" 
                      {  print "values qty_extract ...\n";
			$TARGET_LOCATION="$LOG_DIR/$host"."_ClientsQtyDetails" ;

         	        ## Checking from TRADES TABLE 
	                $QUERY="select o.CLIENT_ACRONYM , sum(QUANTITY) from TRADES o where o.SESSION_ID in ( $SESSION ) and o.JULIAN_DATE = '$julian_date'  group by o.CLIENT_ACRONYM into outfile '$TARGET_LOCATION' fields terminated by ',' ;" ;

                        break;
			}
                case "cumqty_search"  
                       {  print "count cumqty_search ..\n" ;
			$TARGET_LOCATION="$LOG_DIR/$host"."_cumqty_count" ;
               		$QUERY="select sum(CUM_QTY) from ORDERS o where o.SESSION_ID in ( $SESSION ) and o.JULIAN_DATE = '$julian_date' into outfile '$TARGET_LOCATION' ;";
                         break;
			}
                case "cumqty_extract" 
                        { print "values cumqty_extract ....\n";
			 $TARGET_LOCATION="$LOG_DIR/$host"."_ClientsCumQtyDetails" ;

	                ## We have to check exactly the ORDER TABLES -> CUM_QTY
                	$QUERY="select o.CLIENT_ACRONYM , sum(CUM_QTY) from ORDERS o where o.SESSION_ID in ( $SESSION ) and o.JULIAN_DATE = '$julian_date'  group by o.CLIENT_ACRONYM into outfile '$TARGET_LOCATION' fields terminated by ',' ;" ;
                        break;
			}
                else
                    {   print "please enter parameter for search ..\n" ; }
        }


&searchSQL();

#####################################################################################################
sub parseFile(){

my $file=shift;
print " File name is $file \n";
open (IN, "<$file") || die "Cannot open file $file $!";
my $line=0;

while (my $session = <IN>) {
	chomp;
	 #skip the header and description.
	if ($line < 1 ){
	my @parts =split(/=/,$session);
	@sessionid= split (/\,/,$parts[1]);
            #print @sessionid;
         }
         $line++;
#	}
}

#print "\n"."Size: ",scalar @sessionid,"\n";

close(IN);

	  foreach $session (@sessionid) {
                $qrystring=$qrystring."'".$session."',";
		# print "\n"."string :".$qrystring;
           }

#       print "\n"."final qry string :".$qrystring;
#       print "\n"."Length of string :".length($qrystring); 	
       print "\n"."qry string :".substr($qrystring ,0,length($qrystring)-1);
	

}

#####################################################################################################

sub searchSQL(){

	       # foreach $host (@AS_HOSTS) {

               $SQL = "$SQL_PATH -u $AS_DB_USER -h $host -e \"$QUERY\" $AS_DB_NAME";
               print "Value of command is ---- $SQL\n";
               my $result = system($SQL);
               print "Value of result is $result\n";

               if($result == 0){
                       print "SQL command successful on $host\n";
               }else{
                       print "SQL command NOT successful on $host\n";
               }

	      #} # end of for
}

