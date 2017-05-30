#!/bin/bash

#############################################
# A simple script used to check the morning SPBGW logs
# author = ekarthik
# date   = 2009/03/18
###############################################

#set -x

USER_INPUT=${1}

getToday=`date +%Y%m%d`

host=`hostname`
echo Host: ${host}

CLIENT_C_P="TDC_SPBGW_CLIENT_C_P"
CLIENT_C_S="TDC_SPBGW_CLIENT_C_S"
CLIENT_Q_P="TDC_SPBGW_CLIENT_Q_P"
CLIENT_Q_S="TDC_SPBGW_CLIENT_Q_S"

# FTP user details

CLIENT_LOG_LOC=/home/aseqpmgp/CCT/SPS/prod/logs

let getPrevDate="${getToday}"-1
echo
#echo "%%%%%%%%%%%%%%%%%%% PreviousDate" ${getPrevDate}
echo

function ReadUserInput  {
        echo -e "Press enter to continue "
        read word
}


function CheckFileExist {

# Ghanshyam Modified this on 01-APR-2009
# Karthik updated this on 06-Apr-2009
# tail -1 is not a suitable to check the system log, so changed to tail-2
#Adding new logic to get latest log file. Getting date component.

date=`ls -ltr /local/1/home/tkeqspsp_local/SPBDMA/SPBDMATKYLX*/logs/SPBDMA* |tail -2 |grep -v console |grep ".log." |cut -d"." -f3`
echo
echo `ls -ltr /local/1/home/tkeqspsp_local/SPBDMA/SPBDMATKYLX*/logs/SPBDMA* |tail -2 |grep -v console |grep ".log."`
echo
}


function CheckProcess {

echo
echo `ps -auxwww |grep SPBDMATKYLX |grep server| cut -c0-148`
}

function CheckFixSessionStats {
        
 if [ ${host} = "asas" -o ${host} = "004" ];then
  cd /local/1/home/tkeqspsp_local/HP/HP2
  log_dir=`pwd`
  echo $log_dir 
  sh CameronAdmin_SPBDMATKYLX5.sh S |grep -v "stdConfig"
  sh CameronAdmin_SPBDMATKYLX5.sh cl_list |grep -v "stdConfig"
  sh CameronAdmin_SPBDMATKYLX5.sh mb_messages |grep -v "stdConfig"
  sh CameronAdmin_SPBDMATKYLX5.sh rdb_status |grep -v "stdConfig"
 fi

 if [ ${host} = "asasa" -o ${host} = "asasas" ];then
 cd /local/1/home/tkeqspsp_local/HP/HP1
  log_dir=`pwd`
  echo $log_dir
  sh CameronAdmin_SPBDMATKYLX3.sh S |grep -v "stdConfig"
  sh CameronAdmin_SPBDMATKYLX3.sh cl_list |grep -v "stdConfig"
  sh CameronAdmin_SPBDMATKYLX3.sh mb_messages |grep -v "stdConfig"
  sh CameronAdmin_SPBDMATKYLX3.sh rdb_status |grep -v "stdConfig"
 fi

 echo  
}


function CheckSPBLogs {
echo
echo
        if [ ${host} = "asasas" -o ${host} = "asasasa" ];then
                egrep -i "ERR|WARN|DISCON|Re-synched" /local/1/home/tkeqspsp_local/SPBDMA/SPBDMATKYLX*/logs/SPBDMATKYLX*.log.${date} | egrep -v "TEST|INFO|Starting session|using default 5000|already used by instument| Series ID 349"|egrep -v "Series ID 109|TEST|Series ID 110 is invalid"
        elif [ ${host} = "asasasa" -o ${host} = "asasas" ]; then
                egrep -i "ERR|WARN|DISCON|Re-synched" /local/1/home/tkeqspsp_local/SPBDMA/SPBDMATKYLX*/logs/SPBDMATKYLX*.log.${date}  | egrep -v  "TKYDMA1_TEST|SPBTKYLX1_TEST|INFO|Starting session|using default 5000|already used by instument| Series ID 373"|grep -v " Series ID 374"|egrep -v "Series ID 109|TEST|Series ID 110 is invalid"
        fi
echo
}

function CheckSpearLogs {
echo
echo
#grep -i "Loaded" /data/eqfixprd/SPBDMA/SPBDMATKYLX*/logs/SPBDMATKYLX*.log.${date}
egrep "Loaded|Initialising positions|external data|cash limit usages" /local/1/home/tkeqspsp_local/SPBDMA/SPBDMATKYLX*/logs/SPBDMATKYLX*.log.${date}
}


function CheckCSTLogs {
echo
echo
        if [ ${host} = "asasas" -o ${host} = "asasa" ];then
                egrep -i "ERR|WARN|DISCON" /local/1/home/tkeqspsp_local/SPBDMA/SPBDMATKYLX*/logs/CST/SPBDMATKYLX*.log.${getToday}
        else
                echo "Secondary box- No CST file present"
        fi
}



if [ "${USER_INPUT}" -eq 0 ];then
 

      if [ ${host} = "asasas" ];then
        temp_file=${CLIENT_Q_P}_${getToday}.txt
      elif [ ${host} = "tkodclxeqpbprd001" ];then
        temp_file=${CLIENT_Q_S}_${getToday}.txt
      elif [ ${host} = "tkodclxeqpbprd004" ];then
        temp_file=${CLIENT_C_P}_${getToday}.txt
      elif [ ${host} = "tkodclxeqpbprd003" ];then
        temp_file=${CLIENT_C_S}_${getToday}.txt
      else
        temp_file=temp_file_${getToday}.txt
      fi

      if [ -s "$temp_file" ] ; then
        rm -rfv $temp_file
      fi


        echo "${getToday}"   >>$temp_file
        echo  "----------"   >>$temp_file
        echo                 >>$temp_file
        CheckFileExist       >>$temp_file
        echo                 >>$temp_file
        echo                 >>$temp_file
        CheckProcess         >>$temp_file
        echo                 >>$temp_file
        echo "CHECK ERR/WARN/DISCONN"   >>$temp_file
        echo "----------------------"  >>$temp_file
        CheckSPBLogs                    >>$temp_file
        echo                            >>$temp_file
        echo                            >>$temp_file
        echo "CHECK MORNNING DATA LOADED OR NOT "       >>$temp_file
        echo  "----------------------------------"      >>$temp_file
        CheckSpearLogs                                  >>$temp_file
        echo "CHECK CST ERR/DISCONN"                    >>$temp_file
        echo "---------------------"                    >>$temp_file
        CheckCSTLogs                                    >>$temp_file
        echo                                            >>$temp_file
        echo "SPBDMA GW....."                           >>$temp_file
        echo  "----------"                              >>$temp_file
        CheckFixSessionStats                            >>$temp_file
else
        CheckFileExist
        echo
        CheckProcess
        echo
        echo
        echo "CHECK ERR/WARN/DISCONN"
        echo  "---------------------"
        ReadUserInput
        CheckSPBLogs
        echo
        echo
        echo "CHECK MORNNING DATA LOADED OR NOT "
        echo  "---------------------------------"
        ReadUserInput
        CheckSpearLogs
        echo
        echo
        echo "CHECK CST ERR/DISCONN"
        echo  "--------------------"
        ReadUserInput
        CheckCSTLogs
        echo
        echo "SPBDMA GW....."
        echo "--------------"
        ReadUserInput
        CheckFixSessionStats
fi


log_dir=`pwd`

echo $temp_file


###### End ftp file  ######

if [ "${USER_INPUT}" -eq 0 ];then
cd
echo "Moving files to logs folder ..."
echo `mv -vf ${temp_file} ${CLIENT_LOG_LOC}`
fi

exit 0

