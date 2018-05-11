@echo off
REM Windows script to move files from one folder to another
REM
REM  @author:     Karthik
REM  @copyright:  2018 Prudential Singapore Services. All rights reserved.
REM 

cd "c:\Tools\Batch-scripts"
SET HOSTFILE_DIR=c:\Windows\System32\drivers\etc
SET BACKUP_DIR=backup

set hostfile=hosts
set BlockedFile=hosts_blocked
set UnBlockedFile=hosts_unblocked

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%"
set "fullstamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"

REM echo datestamp: "%datestamp%"
REM echo timestamp: "%timestamp%"

echo "Running ... CurrentTimeStamp :->%fullstamp%"
dir /b %HOSTFILE_DIR%\%BACKUP_DIR% 

copy /Y %HOSTFILE_DIR%\%BACKUP_DIR%\%UnBlockedFile% %HOSTFILE_DIR%\%hostfile%

echo "OutputFile ...output\HostValidation_UnBlocked_%datestamp%-%timestamp%.csv"

python HostValidator.py -o output\HostValidation_UnBlocked_%datestamp%-%timestamp%.csv

timeout /t 5

copy /Y %HOSTFILE_DIR%\%BACKUP_DIR%\%BlockedFile% %HOSTFILE_DIR%\%hostfile%

python HostValidator.py -o output\HostValidation_Blocked_%datestamp%-%timestamp%.csv

