#!/bin/bash

#####################################################################
# A simple script used to check the morning process and logs
# this will help us to make sure that application is ready for business.
# This script reads input conf file line by line and sets the param 
# based on client code
# ClientCode =C,Q,T
# -----------------------------------------------
# author :ekarthik
# date   = 2009/03/18
# LastModified = 2009/09/28 
#####################################################################

#set -x

### Main script stars here ###
# Store file name
FILE="/home/aseqpmgp/CCT/SPS/prod/bin/check/HPMornCheckParams.conf"

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

# This will get the basedirectory
 BASE_DIR=$(echo ${textArray[2]} | awk -F= '{print $2}' )

# get length of array
len=$(expr $c - 1 )

i=0;

USER_INPUT=${1}

# using i to set the input client code 
# ClientCode =Q,C,TTF 
# ClientCode Q=> i=0
# ClientCode C=> i=1
# ClientCode TTF=> i=2
# ClientCode YXiZ=> i=3
# This we will get as a argument 2
 
#let i=$2*18+2
let i=$2*19+5

  F1=$(echo ${textArray[$i]} | awk -F= '{print $2}' )
  F2=$(echo ${textArray[$i+1]} | awk -F= '{print $2}' )
  F3=$(echo ${textArray[$i+2]} | awk -F= '{print $2}' )
  F4=$(echo ${textArray[$i+3]} | awk -F= '{print $2}' )
  F5=$(echo ${textArray[$i+4]} | awk -F= '{print $2}' )
  F6=$(echo ${textArray[$i+5]} | awk -F= '{print $2}' )

  F7=$(echo ${textArray[$i+6]} | awk -F= '{print $2}' )
  F8=$(echo ${textArray[$i+7]} | awk -F= '{print $2}' )
  F9=$(echo ${textArray[$i+8]} | awk -F= '{print $2}' )

  F10=$(echo ${textArray[$i+9]} | awk -F= '{print $2}' )
  F11=$(echo ${textArray[$i+10]} | awk -F= '{print $2}' )
  F12=$(echo ${textArray[$i+11]} | awk -F= '{print $2}' )
  F13=$(echo ${textArray[$i+12]} | awk -F= '{print $2}' )
  F14=$(echo ${textArray[$i+13]} | awk -F= '{print $2}' )
  
  F15=$(echo ${textArray[$i+14]} | awk -F= '{print $2}' )
  F16=$(echo ${textArray[$i+15]} | awk -F= '{print $2}' )
  F17=$(echo ${textArray[$i+16]} | awk -F= '{print $2}' )
  F18=$(echo ${textArray[$i+17]} | awk -F= '{print $2}' )
  #F19=$(echo ${textArray[$i+18]} | awk -F= '{print $2}' )
  #F20=$(echo ${textArray[$i+19]} | awk -F= '{print $2}' )

  IFS=$BAKIFS


getToday=`date +%Y%m%d`

host=`hostname`
echo Host: ${host}

CLIENT_P=${F1}
CLIENT_S=${F2}

CLIENT_LOG_LOC=${F5}

SPEAR_HOME="${BASE_DIR}/position-file/morning/prd/SPEAR_POSITIONS.REC"

checkFor=`echo "${F8}" |cut -f1 -d"*"`

let getPrevDate="${getToday}"-1
echo
#echo "%%%%%%%%%%%%%%%%%%% PreviousDate" ${getPrevDate}
echo

function ReadUserInput  {
        echo -e "Press enter to continue "
        read word
}

function CheckLog {
if [ ${host} = ${F3} -o ${host} = ${F4} ];then
	#
	# Common I & V logs are internally stored
	#
        filterI="java.sql.SQLRecoverableException|StaticDataException|ERR|WARN|DISCON|Re-synched|cache"   
        filterV="ORDSVR.* is down|already used by instument|stdConfig|already set up|CSVParser|SPBRMIClientSocketFactory.*ServerConnector|A null command has been read|SessionPersisterImpls|command is empty|Series|NackMsgHandler|IGNORE_WARNINGS|ERROR_LEVEL|Create Listener failed|Internal\(JMIS\) Error|ERROR\[0\]|05:00:[0-5][0-9]:|IGNORE_WARNINGS|ERROR_LEVEL"

	echo
	echo
	echo
	date=`cd ${F6}/logs;ls -ltr|tail -4 |grep "${checkFor}" |egrep -v "sender|console|FIXEventPatroler|PROCCHECKSTART" |grep ".log.${getToday}" |cut -d"." -f3`
	
#	echo "Taking ${date} log file"

	echo "Check for Error in logs - [${date}]"
	echo "______________________________"

	cd $F6/logs
	log_dir=`pwd`
	echo $log_dir

 	checkGrepICount=`echo "${F9}" |wc -w`
        checkGrepVCount=`echo "${F10}" |wc -w`

        if [ ${checkGrepICount} -gt 0 ];then
                Gen_LogGrepI="${filterI}|${F9}"
        else
                Gen_LogGrepI="${filterI}"
        fi

        if [ ${checkGrepVCount} -gt 0 ];then
        	Gen_LogGrepV="${filterV}|${F10}"
        else
	        Gen_LogGrepV="${filterV}"
        fi


	  #logfile=`ls -ltr $F8${date}|cut -d" " -f10`
	  echo "Log file Name : "`ls -ltr ${F8}.${date} | cut -f5-12 -d" "`
	  echo
	  #egrep -i -s ${F09} -v -s ${F10}  ${F8}.${date}|cut -c19-500
	  egrep -i ${Gen_LogGrepI} ${F8}.${date} | egrep -v "${Gen_LogGrepV}"
else
          echo "Client host mismatch - run with correct details"
fi
echo
echo


}

function CheckProcess {

echo
echo "Process Status - ${checkFor}"
echo "_______________________"
echo
echo `ps -auxwww |grep ${checkFor} |grep server|cut -c0-120`
}

function CheckPort {
echo
echo

echo "---> Checking various Port Status...."
echo
echo
echo "Client Connection Status"
echo "________________________"
netstat -na|egrep "${F11}"

echo
echo "SPB DB Connection Status"
echo "________________________"
netstat -na|egrep "1521"
echo

echo
echo "RMI Port Status - PC GUI"
echo "________________________"
netstat -na|egrep "${F12}"|grep -v TIME_WAIT
echo
echo
echo "OA Connection with JMIS"
echo "________________________"
echo
echo "...for OSA/JDQ...( Order Line )"
netstat -na|egrep "${F14}"
echo
echo "...for TYO...( Order Lines )"
netstat -na|egrep "${F15}"
echo
echo "...for GWXfr...( Execution lines )"
netstat -na|egrep "${F16}"
echo

}


function CheckSessionStatus {
 echo

 if [ ${host} = "$F3" -o ${host} = "$F4" ];then
  cd $F6
  log_dir=`pwd`
  echo $log_dir
  sh $F7 S |egrep -v "terminating|stdConfig"
  echo "Check Cluster Status"
  echo "___________________"
  sh $F7 cl_list |egrep -v "terminating|stdConfig"
  echo "Check Buffered Message Status"
  echo "_____________________________"
  sh $F7 mb_messages |egrep -v "terminating|stdConfig"
  echo "Check Static Data - Instruments Status"
  echo "_____________________________"
  sh $F7 rdb_status |egrep -v "terminating|stdConfig"
  
  #echo "ABML 9037.T - Status"
  #echo "%%%%%%%%%%%%%%%%%%%%%%"
  #sh $F7 "spbval pos 602 9037.T" |egrep -v "terminating|stdConfig"



  if  [ ${host} = "$F3"  -a  ${F17} != "NO" ];then

  seriesCount=`echo "${F17}" | awk -F";" '{print NF}'`
  #echo $seriesCount

  for  (( i = 1 ; i < ${seriesCount}+1  ; i++ ));
    do
          getEachSeries=`echo "${F17}" | cut -d";" -f$i`
          getSeries=`echo "${getEachSeries}" |cut -f1 -d"|"`
	  getBookCode=`echo "${getEachSeries}" |cut -f2 -d"|"`

          getValue=`expr $i % 2`

         # echo "getBookCode:${getBookCode} getValue:${getValue} i=$i"

          if [ ${getValue} -eq 0 ];then
           getRic=`cat ${SPEAR_HOME} | grep ${getBookCode} |tail -1| cut -f4 -d","`
          else
           getRic=`cat ${SPEAR_HOME} | grep ${getBookCode} |head -1| cut -f4 -d","`
          fi


          echo "Check Postion Status - Series-${getSeries} RIC -${getRic}"
          echo "_______________________________________________________"
          sh $F7 "spbval pos ${getSeries} ${getRic}" |egrep -v "terminating|stdConfig"
    done
   fi
  
  
  echo "Priming symbol - Status"
  echo "_____________________________"
  sh $F7 rdb_codes 5 HPPRM.T |egrep -v "terminating|stdConfig"



 fi

 echo
}


if [ "${USER_INPUT}" -eq 0 ];then

      if [ ${host} = "$F3" ];then
        temp_file=${CLIENT_LOG_LOC}/${CLIENT_P}_${getToday}.txt
      elif [ ${host} = "$F4" ];then
        temp_file=${CLIENT_LOG_LOC}/${CLIENT_S}_${getToday}.txt
      else
        temp_file=${CLIENT_LOG_LOC}/temp_file_${getToday}.txt
      fi

      if [ -s "$temp_file" ] ; then
        rm -rfv $temp_file
      fi


        echo "${getToday}"   >>$temp_file
        echo  "----------"   >>$temp_file
        echo                 >>$temp_file
        CheckProcess         >>$temp_file
        echo                 >>$temp_file
        echo "Check FixSession Status"     >>$temp_file
        echo "-----------------------"     >>$temp_file
        CheckSessionStatus                 >>$temp_file
        CheckPort             >>$temp_file
        echo                  >>$temp_file
        echo                 >>$temp_file
        CheckLog             >>$temp_file
        echo                 >>$temp_file

else
        CheckProcess
        echo
        ReadUserInput
        echo
        CheckLog
        echo
        CheckSessionStatus
        echo
        CheckPort
        echo
fi


echo $temp_file

######### Moving files to log folder ##############

if [ "${USER_INPUT}" -eq 0 ] ; then
echo "Moving files to logs folder ..."
echo `mv -vf ${temp_file} ${CLIENT_LOG_LOC}`
fi

exit 0


