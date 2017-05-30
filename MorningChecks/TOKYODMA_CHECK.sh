#!/bin/bash

#####################################################
# A script used to call all the morning check scripts
# -----------------------------------------------
# author :ekarthik
# date   :2009/05/11
#########################################################

#set -x

# Make sure we get file name as command line argument
# Else read it from standard input device
if [ "$1" == "" ]; then
   FILE="/home/aseqpmgp/CCT/SPS/prod/bin/check/HPMornCheckParams.conf"
else
   FILE="$1"
   # make sure file exist and readable
   if [ ! -f $FILE ]; then
        echo "$FILE : does not exists"
        exit 1
   elif [ ! -r $FILE ]; then
        echo "$FILE: can not read"
        exit 2
   fi
fi
# read $FILE using the file descriptors
textArray[0]="" # hold text
c=0 # counter
getToday=`date +%Y%m%d`

# Set loop separator to end of line
BAKIFS=$IFS
IFS=$(echo -en "\n\b")
exec 3<&0
exec 0<$FILE
while read line
do
         #store_var=awk '/CLIENT_/ {print $1}' $line
         textArray[$c]=$line # store line
         c=$(expr $c + 1) # increase counter by 1
done
exec 0<&3
   echo " Read & stored in an array .."

function userCheck
{
        USER=`whoami`
        AUTH_USER="tkeqspsp"

        if [ ${USER} = ${AUTH_USER} ]; then
                ssh ${F5} "${F1}/bin/check/${F8}"
                sleep 5;
                ssh ${F6} "${F1}/bin/check/${F8}"
                #echo "passed all Morning checks ..."
        else
                echo
                echo
                echo "Please run this script as tkeqspsp "
                echo "**********************************"
        fi

}

function setData {

        LOG_LOCATION="${F1}/logs"
        FILE_P="$F3"_${getToday}.txt
        FILE_S="$F4"_${getToday}.txt

        FILE_P_LOC=${LOG_LOCATION}/${FILE_P}
        FILE_S_LOC=${LOG_LOCATION}/${FILE_S}
}
##
## This function used to check that, all the files has been
## received or not.
##
##
 function CheckFilesReceivedOrNot
    {

      for f in $( find ${LOG_LOCATION} -daystart -type f -mtime -1 |grep $grep_check  |grep txt | sort ); do
	 
	c=`echo $f |cut -f8 -d"/"`

        echo  $f ..FileName ...[${c}];

         if [ ${c} = ${FILE_P} ]; then
                echo "PRIMARY [${F5}] "     >>tdc_hp_client_mail
                echo "----------------"    >>tdc_hp_client_mail
                cat ${FILE_P_LOC}     	     >>tdc_hp_client_mail
                echo                         >>tdc_hp_client_mail
                echo                         >>tdc_hp_client_mail
        elif [ ${c} = ${FILE_S} ]; then
                echo "SECONDARY [${F6}] "   >>tdc_hp_client_mail
                echo "-------------------"    >>tdc_hp_client_mail
                cat ${FILE_S_LOC}             >>tdc_hp_client_mail
                echo                          >>tdc_hp_client_mail
                echo                          >>tdc_hp_client_mail

         fi

        done

    }

function sendMailReport {

# declare no of files to be checked
NUM=2
std_dateformat=`date +%Y/%m/%d`
#MAIL_TO=sps_it_svc-as@me.com
MAIL_TO=${F2}
#MAIL_TO=gupadhya@me.com

MAIL_SUBJECT="${F7} [$std_dateformat] - ( TDC )"
MAIL_SUBJECT_FILE_MISSING="[WARN] TDC_HP-MorningCheck Logs-Client files missing [$std_dateformat]."

#grep_check=`echo $F4|cut -c1-16`
grep_check=`echo $F4|cut -f1-4 -d"_"`
grep_check=$grep_check"_"
 
CHECKLIST=$(find ${LOG_LOCATION}  -daystart -type f -mtime -1 -printf  '%c %kk  %p \n'| grep $grep_check | wc -l)


        if [ "$CHECKLIST" -eq "$NUM" ]; then
                  CheckFilesReceivedOrNot
                  PROCESS=0;
        elif  [ "$CHECKLIST" -lt "$NUM" ]; then
                 echo "One (or) More tkdma files are missing, AvailableCount=$CHECKLIST " >>tdc_hp_client_mail
                 (cat tdc_hp_client_mail ; ) | \mail -s "${MAIL_SUBJECT_FILE_MISSING}" "${MAIL_TO}" ;
                  PROCESS=-1;
        else
                 echo "More file found please check logs directory. AvailableCount=$CHECKLIST " >>tdc_hp_client_mail
                 PROCESS=0;
        fi


        if [ "$PROCESS" -eq "0" ];then
           # send mail to support team.
        (cat tdc_hp_client_mail; ) | \mail -s "${MAIL_SUBJECT}" "${MAIL_TO}" ;
        else
         rm -rfv tdc_hp_client_mail
        fi

        # clear temporary files

        rm -rfv tdc_hp_client_mail

}

# get length of array
len=$(expr $c - 1 )

#echo Size of array :: $len
#Check for all the available clients 
CheckAllClients=`cat ${FILE} |grep -i "primary"|wc -l`

# use for loop to reverse the array
  F1=$(echo ${textArray[2]} | awk -F= '{print $2}' )
  F2=$(echo ${textArray[3]} | awk -F= '{print $2}' )

# Check and send reports in mail

for (( i=2,j=0; i<$len - 2 && j<${CheckAllClients} ; i=$i+19,j++ ));
do

  F3=$(echo ${textArray[$i+3]} | awk -F= '{print $2}' )
  F4=$(echo ${textArray[$i+4]} | awk -F= '{print $2}' )
  F5=$(echo ${textArray[$i+5]} | awk -F= '{print $2}' )
  F6=$(echo ${textArray[$i+6]} | awk -F= '{print $2}' )
  F7=$(echo ${textArray[$i+20]} | awk -F= '{print $2}' )
  F8="MornCheckTkdma.sh 0 $j"

  userCheck
  setData
  sendMailReport
done
 
sleep 1

exit 0;

