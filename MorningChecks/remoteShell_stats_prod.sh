#!/bin/ksh
#!/opt/perl-5.8.0/bin/perl

# $Id: remoteShell.sh,v 1.2 2008/11/20 11:19:12 orrr Exp $
# $Source: /export/ro/u1/cvs/cvsroot/SPBValidator/config/shared/remoteShell.sh,v $

unset LC_CTYPE
unset LANG
appDir="/local/1/home/tkeqspsp_local/SPBDMA/"$2p
#appDir=`dirname $0`
cd $appDir

#if [ ! -f /home/apadm029/MorningChecks/stage/app_stage.config ]
#then
#    echo must be run from within a hub directory
#    exit 1
#fi

#------------------------------------------------------
#------------------------------------------------------
#. /home/apadm029/MorningChecks/stage/app_stage.config
# File contnet from app_stage.config are now [asted below.
#------------------------------------------------------
#------------------------------------------------------

##############
# App configuration, sourced by scripts.
# Must match the xml config.
# $Id: app.config,v 1.1 2008/11/20 12:08:01 orrr Exp $

appHost=$1

appCluster=$2
appServer=$2p
rmiName=rmiAPP${appCluster}
rmiPort=$3

#perlLoc=/export/rw/u1/fred/perl/perl-5.8.8/bin/perl
#javaLoc=/apps/java/i686/RHEL5/1.6.0_07
#perlLoc=/local/1/home/tkeqspsp_local/SPBDMA/perl/perl-5.8.8/bin/perl
perlLoc=/usr/bin/perl
#push @INC,"/local/1/home/tkeqspsp_local/SPBDMA/perl/perl-5.8.8/lib";
export perlLoc

javaLoc=/local/1/home/tkeqspsp_local/SPBDMA/jdk/jdk1.5.0_11
export javaLoc

DEBUG_PORT=13500
export DEBUG_PORT

#WEB_PORT=10088

#export WEB_PORT

MEM_SZ=2000M
export MEM_SZ

##############

MEM_MSZ=32M
export MEM_MSZ


#$perlLoc ../util/unix/secureRemoteConsole.pl \
$perlLoc /local/1/home/tkeqspsp_local/SPBDMA/util/unix/secureRemoteConsole.pl \
        ${rmiName}_$appServer $appHost $rmiPort <<EOF
s_stats
cl_list
mb_messages
rdb_status
quit
EOF

