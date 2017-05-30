#!/bin/bash

#######################################################################################
# Description :A simple script used to check the SPBGUI  process is running or not.
# 		1) This will help us to make sure that application is ready for business.
# 		2) This script reads input from conf file and sets the parameter.
#  
# 
# author :ekarthik
# date   = 2009/06/30
##########################################################################################

#set -x

### Main script stars here ###
# Store file name
FILE="/home/aseqpmgp/CCT/SPS/prod/bin/check/SPBGUICheckParams.conf"

# Make sure we get file name as command line argument
# Else read it from standard input location or prod location

# make sure file exist and readable
   if [ ! -f $FILE ]; then
        echo "$FILE : does not exists"
        exit 1
   elif [ ! -r $FILE ]; then
        echo "$FILE: can not read"
        exit 2
   fi

# read $FILE using the file descriptors

textArray[0]="" # hold text
c=0 # counter

# Set loop separator to end of line
BAKIFS=$IFS
IFS=$(echo -en "\n\b")
exec 3<&0
exec 0<$FILE

while read line
do
         textArray[$c]=$line # store line
         c=$(expr $c + 1) # increase counter by 1

done

exec 0<&3
#echo " Read & stored in an array .."

# get length of array
len=$(expr $c - 1 )



#echo Size of array :: $len

function CheckProcess {

echo                       
echo "SPBGUI Status - ${1} PORT:$3"
echo
telnet -E $2 $3 </dev/null |grep -i "Conn"
echo "______________________________________"

}

# use for loop to reverse the array
  dir=$(echo ${textArray[2]} | awk -F= '{print $2}' )
  mail_to=$(echo ${textArray[3]} | awk -F= '{print $2}' )

#echo "check Base dir "$dir
#echo "Mail to "$mail_to
 getToday=`date +%Y%m%d`

 LOG_DIR=${dir}/logs
 LOG_FILENAME=SPBGUI_STATUS_${getToday}

function sendMailReport {

dateFormat=`date +%Y/%m/%d`
MAIL_TO=${mail_to}

MAIL_SUBJECT="[OK] - SPBGUI status check - [$dateFormat]"
MAIL_SUBJECT_ERR="[NG] -SPBGUI status check [$dateFormat]."

CheckDisConn=`cat ${LOG_DIR}/${LOG_FILENAME} |grep -i "disconn|fail|refuse" |wc -l`
CheckConn=`cat ${LOG_DIR}/${LOG_FILENAME} |grep -i "conn" |wc -l`

	if [[ ${CheckDisConn} -gt 0 || ${CheckConn} -lt $1 ]] ; then
		(cat ${LOG_DIR}/${LOG_FILENAME}; ) | \mail -s "${MAIL_SUBJECT_ERR}" "${MAIL_TO}" ;
	else
		(cat ${LOG_DIR}/${LOG_FILENAME}; ) | \mail -s "${MAIL_SUBJECT}" "${MAIL_TO}" ;
	fi


}


rm -rfv ${LOG_DIR}/${LOG_FILENAME}
#Put in loop to send all the client reports in mail
let clientCount=0
for (( i=5; i<$len ; i=$i+4 ));
do
 
  F1=$(echo ${textArray[$i]}  | awk -F= '{print $2}' )
  F2=$(echo ${textArray[$i+1]} | awk -F= '{print $2}' )
  F3=$(echo ${textArray[$i+2]} | awk -F= '{print $2}' )

  #echo  --$i  Client :${F1} ,Host:${F2} ,port ${F3}
	
  seriesCount=`echo "${F3}" | awk -F";" '{print NF}'`

   if [ $seriesCount -gt 1 ];then
	let count=${seriesCount}+1
   	for  (( j = 1 ; j <count ; j++ ));
	    do
        	 getEachPort=`echo ${F3} | cut -f$j -d";"`
	         CheckProcess ${F1} ${F2} ${getEachPort} >>${LOG_DIR}/${LOG_FILENAME}
	         let clientCount=$clientCount+1 	
	   done
	count=0
   else
  	if [[  -n "${F2}"  &&  -n "${F3}" &&  ${seriesCount} -gt 0 ]]; then
   		CheckProcess ${F1} ${F2} ${F3} >>${LOG_DIR}/${LOG_FILENAME}
		let clientCount=$clientCount+1
        fi
   fi
   
   	 seriesCount=0
done


sendMailReport $clientCount

echo "GUI report mail sent"

exit 0
