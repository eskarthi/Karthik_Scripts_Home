#!/usr/bin/perl

########################################################################
## 	E2E Interactive Integration Test Context Generator      ####
##	    							####
##      							####
########################################################################

use strict;
use warnings;
use Getopt::Long;
use FindBin '$Bin';

## Default context name
my $context = "MA_FCAIRS_APP:20140220,MA_FCAIRS_REJ:20140222";

## Default environment
my $environment = "DEV";

# Timeout in seconts
my $timeOut = 20;

GetOptions ("c|context=s"  => \$context,
            "e|environment=s" => \$environment,
            "t|timeout=i" => \$timeOut) or die "Couldn't process script options: $!";

sub getEnv{

    my $filename = shift;
    my $prefix = shift;

    open my $fhandler, "<", $filename or die "Could not open $filename: $!";


    while (<$fhandler>) {
        chomp;
        my ($k, $v) = split /=/, $_, 2;
        $v =~ s/\$([a-zA-Z_]\w*)/$ENV{$1}/g;
        $v =~ s/`(.*?)`/`$1`/ge;
        $ENV{${prefix}."_".$k} = $v;
    }
}

sub query{

    my ($usr,$pw,$svc, @qry)=@_;

    my @query =();

    push(@query,"sqlplus -S /nolog <<EOF\nconnect $usr/$pw\@$svc;\n");
    push(@query,"SET SERVEROUTPUT ON;\n");
    push(@query,"SET ECHO OFF;\n");
    push(@query,"SET VERIFY OFF;\n");
    push(@query,"SET Heading OFF;\n");
    push(@query,"SET LINESIZE 5000;\n");
    push(@query,"SET NEWPAGE NONE;\n");
    push(@query,"SET PAGESIZE 0;\n");
    push(@query,"SET Heading OFF;\n");
    push(@query,"SET FEEDBACK OFF;\n");
    push(@query,"SET COLSEP ,;\n");
    push(@query,(@qry,"\n"));
    push(@query,"commit;\n");
    push(@query,"EOF\n");

    my $q = join('',@query);
    my @out = `$q`;

    my @merror = grep(/.*ERROR.*/, @out);

    if($#merror>=0){
        print "Error executing SQL clause:\n\n@out\n\n";
        exit 1;
    }

    my @pout = map { s/[ \t]+,/,/g;s/,[ \t]+/,/g; $_; } @out;

    return @pout;
}

system("dos2unix $Bin/XODS_OWNER.${environment}.config &>/dev/null");
getEnv("$Bin/XODS_OWNER.${environment}.config","XODS");

my @values=split (',', $context);

# truncate context & context_payload table.
query($ENV{XODS_DB_OWNER},$ENV{XODS_DB_OWNER_PASSWORD},$ENV{XODS_DB_SERVICE},"truncate table context_payload;");
print "truncating table context_payload.. \n";

query($ENV{XODS_DB_OWNER},$ENV{XODS_DB_OWNER_PASSWORD},$ENV{XODS_DB_SERVICE},"truncate table context;");
print "truncating table context.. \n";

system("./00_env_load_DCPP_OWNER.pl -c $values[0] -e $environment");


foreach my $contextValue (@values) {

system("./01_env_load_XODS_OWNER.pl -c $contextValue -e $environment");

print "Timeout is set to $timeOut secods\n";
print "Context name is $contextValue\n";

print "Verifying context payload...";

my @result = query($ENV{XODS_DB_OWNER},$ENV{XODS_DB_OWNER_PASSWORD},$ENV{XODS_DB_SERVICE},"select * from context_payload where name = '".$contextValue."';");

my $expectedPayload = 53;
my $actualPayload = $#result + 1;

if($actualPayload!=$expectedPayload){
    print "[Failed] Expected count was $expectedPayload but actual count was $actualPayload\n";
    exit 1;
}else{
    print "[OK] $actualPayload trades were loaded\n";
}

print "Triggering end to end interactive test for context $contextValue...";

query($ENV{XODS_DB_OWNER},$ENV{XODS_DB_OWNER_PASSWORD},$ENV{XODS_DB_SERVICE}, "execute CONTEXT_SERVICE.openContext('$contextValue');");
query($ENV{XODS_DB_OWNER},$ENV{XODS_DB_OWNER_PASSWORD},$ENV{XODS_DB_SERVICE}, "execute CONTEXT_SERVICE.closeContext('$contextValue','ROW_COUNT');");

print "[OK]\n";


$contextValue =~ m/([^:]+):.*/;
my $cname = $1;

print "cname : $cname \n";

my @contextQuery = query($ENV{XODS_DB_OWNER},$ENV{XODS_DB_OWNER_PASSWORD},$ENV{XODS_DB_SERVICE}, "select * from xods_owner.context where name like '\%$cname\%' ORDER BY STATE;");

print "row size: $#contextQuery\n";

my $contextRows = $#contextQuery+1;

if($contextRows!=2){
    print "[Failed] There should be exactly two records associated with context but $contextRows were found\n";
    exit 1;
}else{
    print "[OK] 2 records found for context $contextValue\n";
}

if($contextQuery[0]=~m/$cname:.*,OPEN,1,.*/){
    print "[OK] Next day's context was successfully opened\n";
}else{
    print "[Failed] Next day's context could not be found\n";
    exit 1;
}

if($contextQuery[1]=~m/$contextValue,VALIDATED,1,ROW_COUNT/){
    print "[OK] Context was successfully validated\n";
}else{
    print "[Failed] Context was not validated\n";
    exit 1;
}

} #End of for [Context and validation finished here]

my $ready =0;
foreach my $contextValue (@values) {

$contextValue =~ m/([^:]+):.*/;
my $cname = $1;

print "Checking Context name : $contextValue\n";

my $ready = 0;
my $sttime = time;
my $elapse = 0;

my @events = ();

while($ready!=1){

     @events = query($ENV{XODS_DB_OWNER},$ENV{XODS_DB_OWNER_PASSWORD},$ENV{XODS_DB_SERVICE}, "select * from xods_owner.event_store where message like '\%$cname\%' ORDER BY EVENT_TIMESTAMP;");
     chomp(@events);

     # Approval event
     if ($cname =~ /APP/) {
     if($events[-1]=~m/[^,]+,ARCHIVAL,[^,]+,ARCHIVED,.*/ ){
     	$ready=1;
     }else{
        sleep(1);
     }
     }

     # Rejection Event

     if ($cname =~ /REJ/) {
     if($events[-1]=~m/[^,]+,MANUAL_APPROVAL,[^,]+,REJECTED,.*/ ){
        $ready=1;
     }else{
        sleep(1);
     }
     }

     $elapse = time - $sttime;

     if ($elapse>$timeOut){
	    $ready=-1;
    	print "\n[Failed] Operation timeout while waiting for events\n";
    	exit 1;
     }

 }#End of While


print "Events registered for context $contextValue\n\n";
map { print "$_\n"; } @events;

}#End of for

    print "\n[OK] Test completed successfuly!\n";


exit 0;