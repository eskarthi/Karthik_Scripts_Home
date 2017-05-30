#!/bin/bash

#################################################################
# A simple script used to send TOKYODMA morning check logs in mail
# author = ekarthik
# date   = 2009/03/18
# Company = Singapore
###############################################################

set -x

MAIL_TO=ekarthik@me.com

MAIL_SUBJECT_C="TKDMA-MorningCheck Client - C `date +%Y/%m/%d` - ( OTE )"
MAIL_SUBJECT_Q="TKDMA-MorningCheck Client - Q `date +%Y/%m/%d` - ( OTE )"
MAIL_SUBJECT_FILE_MISSING="[WARN] TKDMA-MorningCheck Logs-Client files missing `date +%Y/%m/%d`."

getToday=`date +%Y%m%d`
LOG_LOCATION="/home/aseqpmgp/CCT/SPS/prod/logs"
FILE_C_P="OTETKDMA_CLIENT_C_P"_${getToday}.txt
FILE_C_S="OTETKDMA_CLIENT_C_S"_${getToday}.txt
FILE_Q_P="OTETKDMA_CLIENT_Q_P"_${getToday}.txt
FILE_Q_S="OTETKDMA_CLIENT_Q_S"_${getToday}.txt

FILE_C_P_LOC=${LOG_LOCATION}/${FILE_C_P}
FILE_C_S_LOC=${LOG_LOCATION}/${FILE_C_S}
FILE_Q_P_LOC=${LOG_LOCATION}/${FILE_Q_P}
FILE_Q_S_LOC=${LOG_LOCATION}/${FILE_Q_S}


CHECKLIST=$(find ${LOG_LOCATION}  -daystart -type f -mtime -1 -printf  '%c %kk  %p \n'| grep TKDMA | grep -v TDC |grep txt | wc -l)

# declare no of files to be checked
NUM=4

##
## This function used to check that, all the files has been 
## received or not.
##
## 
 function CheckFilesReceivedOrNot
    {

      for f in $( find ${LOG_LOCATION} -daystart -type f -mtime -1 |grep TKDMA |grep -v TDC |grep txt ); do
        c=`echo $f |cut -c34-65`

        echo  $f ..FileName ...[${c}];

        if [ ${c} = ${FILE_C_P} ]; then
                echo "PRIMARY C Logs"   >>tkdma_client_c_mail
		echo "-------------"    >>tkdma_client_c_mail
		cat ${FILE_C_P_LOC}     >>tkdma_client_c_mail
		echo                    >>tkdma_client_c_mail
		echo                    >>tkdma_client_c_mail
         elif [ ${c} = ${FILE_C_S} ]; then
		echo                    >>tkdma_client_c_mail
		echo "---------------"  >>tkdma_client_c_mail
		echo "SECONDARY C Logs" >>tkdma_client_c_mail
		echo "---------------"  >>tkdma_client_c_mail
		cat ${FILE_C_S_LOC}     >>tkdma_client_c_mail
         elif [ ${c} = ${FILE_Q_P} ]; then
                echo "PRIMARY Q Logs"   >>tkdma_client_q_mail
		echo "-------------"    >>tkdma_client_q_mail
		cat ${FILE_Q_P_LOC}     >>tkdma_client_q_mail
		echo                    >>tkdma_client_q_mail
		echo                    >>tkdma_client_q_mail
	elif [ ${c} = ${FILE_Q_S} ]; then
                echo "SECONDARY Q Logs" >>tkdma_client_q_mail
                echo "-------------"    >>tkdma_client_q_mail
                cat ${FILE_Q_S_LOC}     >>tkdma_client_q_mail
                echo                    >>tkdma_client_q_mail
                echo                    >>tkdma_client_q_mail

         fi

        done

    }

if [ "$CHECKLIST" -eq "$NUM" ]; then
  CheckFilesReceivedOrNot
  PROCESS=0;
elif  [ "$CHECKLIST" -lt "$NUM" ]; then
 echo "One (or) More tkdma files are missing, AvailableCount=$CHECKLIST " >>tkdma_client_mail
 (cat tkdma_client_mail ; ) | \mail -s "${MAIL_SUBJECT_FILE_MISSING}" "${MAIL_TO}" ; 
  PROCESS=-1;
else
 echo "More file found please check logs directory. AvailableCount=$CHECKLIST " >>tkdma_client_mail	
 PROCESS=0;
fi


if [ "$PROCESS" -eq "0" ];then
   # send mail to support team.
(cat tkdma_client_c_mail; ) | \mail -s "${MAIL_SUBJECT_C}" "${MAIL_TO}" ;
(cat tkdma_client_q_mail; ) | \mail -s "${MAIL_SUBJECT_Q}" "${MAIL_TO}" ;
else
 rm -rfv tkdma_client_mail
fi

# clear temporary files

rm -rfv tkdma_client_c_mail
rm -rfv tkdma_client_q_mail

exit 0;
