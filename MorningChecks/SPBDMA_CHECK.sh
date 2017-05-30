
#!/bin/bash

#####################################################
# A script used to call all the morning check scripts and send SPBGW morning check logs in mail
# author  = ekarthik
# date    = 2009/04/07
#####################################################

set -x

USER=`whoami`
AUTH_USER="asdsaas"


MAIL_TO=qps_asia_alerts@
#MAIL_TO=ekarthik@me.com

MAIL_SUBJECT_T="SPBGW-MorningCheck Client - TUDP `date +%Y/%m/%d` - ( OTE )"
MAIL_SUBJECT_FILE_MISSING="[WARN] TUDOR_SPBGW-MorningCheck - Client files missing `date +%Y/%m/%d`."

getToday=`date +%Y%m%d`
LOG_LOCATION="/home/aseqpmgp/CCT/SPS/prod/logs"
FILE_T_P="OTESPBGW_CLIENT_T_P"_${getToday}.txt
FILE_T_S="OTESPBGW_CLIENT_T_S"_${getToday}.txt

FILE_T_P_LOC=${LOG_LOCATION}/${FILE_T_P}
FILE_T_S_LOC=${LOG_LOCATION}/${FILE_T_S}


CHECKLIST=$(find ${LOG_LOCATION}  -daystart -type f -mtime -1 -printf  '%c %kk  %p \n'| grep txt |grep OTESPBGW_CLIENT_T | wc -l )

# declare no of files to be checked
NUM=2

##
## This function used to check that, all the files has been
## received or not.
##
##
 function CheckFilesReceivedOrNot
    {

      for f in $( find ${LOG_LOCATION} -daystart -type f -mtime -1 |grep txt |grep OTESPBGW_CLIENT_T  ); do
        c=`echo $f |cut -c34-67`
        echo  $f ..FileName ...[$c];

        if [ $c = ${FILE_T_P} ]; then
                echo "PRIMARY T Logs"   >>tdc_client_t_mail
                echo "-------------"    >>tdc_client_t_mail
                cat ${FILE_T_P_LOC}     >>tdc_client_t_mail
                echo                    >>tdc_client_t_mail
                echo                    >>tdc_client_t_mail
         elif [ $c = ${FILE_T_S} ]; then
                echo                    >>tdc_client_t_mail
                echo "---------------"  >>tdc_client_t_mail
                echo "SECONDARY T Logs" >>tdc_client_t_mail
                echo "---------------"  >>tdc_client_t_mail
                cat ${FILE_T_S_LOC}     >>tdc_client_t_mail

         fi

        done

    }

echo "Started  Checks"


if [ "$CHECKLIST" -eq "$NUM" ]; then
 CheckFilesReceivedOrNot
  PROCESS=0;
elif  [ "$CHECKLIST" -lt "$NUM" ]; then
 echo "One (or) More OTESPBGW files are missing, AvailableCount=$CHECKLIST " >>spbgw_tdc_client_mail
 (cat spbgw_tdc_client_mail ; ) | \mail -s "${MAIL_SUBJECT_FILE_MISSING}" "${MAIL_TO}" ;
  PROCESS=-1;
else
  echo "More files found please check logs directory. AvailableCount=$CHECKLIST " >>tdc_client_t_mail
  CheckFilesReceivedOrNot
  MAIL_SUBJECT_T=$MAIL_SUBJECT_T "- More files found AvailableCount=$CHECKLIST"
  PROCESS=0;
fi

#elif  [ "$CHECKLIST" -lt "$NUM" ]; then
# echo "One or More files are missing, AvailableCount=$CHECKLIST " >>tdc_client_t_mail
# echo >>tdc_client_t_mail
# CheckFilesReceivedOrNot
#fi

# send mail to support team.
if [ "$PROCESS" -eq "0" ];then
(cat tdc_client_t_mail; ) | \mail -s "${MAIL_SUBJECT_T}" "${MAIL_TO}" ;
else
 rm -rfv spbgw_tdc_client_mail
fi

# clear temporary files

rm -rfv tdc_client_t_mail

echo "Finished Checks"

exit 0;

