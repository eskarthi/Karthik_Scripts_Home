#!/bin/csh -f

setenv ENVIRONMENT	nsc
source /home/tkeqmldp_local/env/x86_64/RHEL5/current/setenv_core

setenv GLUE_SERVER_LOG	/home/tkeqmldp_local/log/GlueServer.out
setenv MAILBODY	/home/aseqpmgp/CCT/SPS/prod/logs/moldmailbody
set TOTAL_STATUS="OK"
set TODAY=`date +%Y/%m/%d`

set PRIMARY_ENV_FILES=( Sequencer.env FailoverSequencer.env Repeater.env HeartbeatChecker.env );
set SECONDARY_ENV_FILES=( FailoverSequencer.env HeartbeatChecker.env Repeater.env Broker.env GlueServer.env );

echo "Primary Host: ${PRIMARY_HOST}" >> $MAILBODY
foreach ENV_FILE ($PRIMARY_ENV_FILES)
	source $CORE_ENV/$ENV_FILE;
	${CORE_SHELL}/ConnectTest.sh ${PRIMARY_HOST} $admin_port /dev/null
	if ($status == 0) then
		set STAT = "OK";
	else
		set STAT = "NG";
		set TOTAL_STATUS = "NG"
	endif
	printf "    %-20s %s\n" "${ENV_FILE:r}:" $STAT >> $MAILBODY
end

echo "" >> $MAILBODY
echo "Secondary Host: ${SECONDARY_HOST}" >> $MAILBODY
foreach ENV_FILE ($SECONDARY_ENV_FILES)
	source $CORE_ENV/$ENV_FILE;
	${CORE_SHELL}/ConnectTest.sh ${SECONDARY_HOST} $admin_port /dev/null
	if ($status == 0) then
		set STAT = "OK";
	else
		set STAT = "NG";
		set TOTAL_STATUS = "NG"
	endif
	printf "    %-20s %s\n" "${ENV_FILE:r}:" $STAT >> $MAILBODY
end

echo "" >> $MAILBODY
echo "ODC GlueClient Host: po0578" >> $MAILBODY
 ${CORE_SHELL}/ConnectTest.sh 172.17.21.155 9106 /dev/null
        if ($status == 0) then
                set STAT = "OK";
        else
                set STAT = "NG";
		set TOTAL_STATUS = "NG"
        endif
        printf "    %-20s %s\n" "GlueClient:" $STAT >> $MAILBODY

echo "" >> $MAILBODY
echo "GLUE Server Log File .." >> $MAILBODY
echo `ls -ltr $GLUE_SERVER_LOG`  >> $MAILBODY
echo "" >> $MAILBODY
echo "TCP Connection for Glue : " >> $MAILBODY

grep "CONNECTION ACCEPTED" $GLUE_SERVER_LOG >> /dev/null

if ($status == 0) then
        printf "    %-20s %s\n" "Connection:" "ESTABLISHED" >> $MAILBODY
else
        printf "    %-20s %s\n" "Connection:" "NOT ESTABLISHED" >> $MAILBODY
	set TOTAL_STATUS = "NG"
endif

echo "" >> $MAILBODY
        printf "    %-20s %s\n" "=======================" >> $MAILBODY
        printf "    %-20s %s\n" "TOTAL STATUS:" $TOTAL_STATUS >> $MAILBODY
        printf "    %-20s %s\n" "=======================" >> $MAILBODY

        if ($TOTAL_STATUS == "OK") then
#                cat $MAILBODY | mail -s "[OK] - MOLD Morning Check [$TODAY]" ghanshyam.upadhyay;
                cat $MAILBODY | mail -s "[OK] - MOLD Morning Check [$TODAY]" qps_asia_alerts@me.com;
        else
                cat $MAILBODY | mail -s "[NG] - MOLD Morning Check [$TODAY]" qps_asia_alerts@me.com;
        endif

/bin/rm -f $MAILBODY
