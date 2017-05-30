#!/bin/bash

#################################################################
# A simple script used to send SPBGW morning check logs in mail
# author = ekarthik
# date   = 2009/03/18
# 
###############################################################

set -x

MAIL_TO=qps_asia_alerts@me.com
#MAIL_TO=gupadhya@me.com
#MAIL_TO=ekarthik@me.com

MAIL_SUBJECT_C="SPBGW-MorningCheck Client - C `date +%Y/%m/%d` - ( OTE )"
MAIL_SUBJECT_Q="SPBGW-MorningCheck Client - Q `date +%Y/%m/%d` - ( OTE )"
MAIL_SUBJECT_FILE_MISSING="[WARN] SPBGW-MorningCheck Logs-Client files missing `date +%Y/%m/%d`."

getToday=`date +%Y%m%d`
LOG_LOCATION="/home/aseqpmgp/CCT/SPS/prod/logs"
FILE_C_P="OTESPBGW_CLIENT_C_P"_${getToday}.txt
FILE_C_S="OTESPBGW_CLIENT_C_S"_${getToday}.txt
FILE_Q_P="OTESPBGW_CLIENT_Q_P"_${getToday}.txt
FILE_Q_S="OTESPBGW_CLIENT_Q_S"_${getToday}.txt

FILE_C_P_LOC=${LOG_LOCATION}/${FILE_C_P}
FILE_C_S_LOC=${LOG_LOCATION}/${FILE_C_S}
FILE_Q_P_LOC=${LOG_LOCATION}/${FILE_Q_P}
FILE_Q_S_LOC=${LOG_LOCATION}/${FILE_Q_S}


CHECKLIST=$(find ${LOG_LOCATION}  -daystart -type f -mtime -1 -printf  '%c %kk  %p \n'| grep txt |grep SPBGW |grep -v TDC |wc -l)

# declare no of files to be checked
NUM=4

##
## This function used to check that, all the files has been 
## received or not.
##
## 
 function CheckFilesReceivedOrNot
    {

      for f in $( find ${LOG_LOCATION} -daystart -type f -mtime -1 |grep txt |grep SPBGW |grep -v TDC ); do
        c=`echo $f |cut -c34-65`
        echo  $f ..FileName ...[$c];

        if [ $c = ${FILE_C_P} ]; then
                echo "PRIMARY C Logs"   >>client_c_mail
		echo "-------------"    >>client_c_mail
		cat ${FILE_C_P_LOC}     >>client_c_mail
		echo                    >>client_c_mail
		echo                    >>client_c_mail
         elif [ $c = ${FILE_C_S} ]; then
		echo                    >>client_c_mail
		echo "---------------"  >>client_c_mail
		echo "SECONDARY C Logs" >>client_c_mail
		echo "---------------"  >>client_c_mail
		cat ${FILE_C_S_LOC}     >>client_c_mail
         elif [ $c = ${FILE_Q_P} ]; then
                echo "PRIMARY Q Logs"   >>client_q_mail
		echo "-------------"    >>client_q_mail
		cat ${FILE_Q_P_LOC}     >>client_q_mail
		echo                    >>client_q_mail
		echo                    >>client_q_mail
	elif [ $c = ${FILE_Q_S} ]; then
                echo "SECONDARY Q Logs" >>client_q_mail
                echo "-------------"    >>client_q_mail
                cat ${FILE_Q_S_LOC}     >>client_q_mail
                echo                    >>client_q_mail
                echo                    >>client_q_mail

         fi

        done

    }


if [ "$CHECKLIST" -eq "$NUM" ]; then
 CheckFilesReceivedOrNot
  PROCESS=0;
elif  [ "$CHECKLIST" -lt "$NUM" ]; then
 echo "One (or) More spbgw files are missing, AvailableCount=$CHECKLIST " >>spbgw_client_mail
 (cat spbgw_client_mail ; ) | \mail -s "${MAIL_SUBJECT_FILE_MISSING}" "${MAIL_TO}" ;
  PROCESS=-1;
else
  echo "More files found please check logs directory. AvailableCount=$CHECKLIST " >>client_c_mail
  echo "More files found please check logs directory. AvailableCount=$CHECKLIST " >>client_q_mail
  CheckFilesReceivedOrNot
  MAIL_SUBJECT_C=$MAIL_SUBJECT_C "- More files found AvailableCount=$CHECKLIST"
  MAIL_SUBJECT_Q=$MAIL_SUBJECT_Q "- More files found AvailableCount=$CHECKLIST" 
  PROCESS=0;
fi

#elif  [ "$CHECKLIST" -lt "$NUM" ]; then
# echo "One or More files are missing, AvailableCount=$CHECKLIST " >>client_c_mail
# echo >>client_c_mail
# CheckFilesReceivedOrNot 	
#fi

# send mail to support team.
if [ "$PROCESS" -eq "0" ];then
(cat client_c_mail; ) | \mail -s "${MAIL_SUBJECT_C}" "${MAIL_TO}" ;
(cat client_q_mail; ) | \mail -s "${MAIL_SUBJECT_Q}" "${MAIL_TO}" ;
else
 rm -rfv spbgw_client_mail
fi

# clear temporary files

rm -rfv client_c_mail
rm -rfv client_q_mail

exit 0;
