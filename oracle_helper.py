#!python
import subprocess
import sys
import os.path


def query(usr, pw, svc, file):
    if os.path.isfile(file):
        sqlplus = []
        sqlplus.append("whenever sqlerror exit sql.sqlcode;\n")
        sqlplus.append("set serveroutput on;\n")
        sqlplus.append("set echo off;\n")
        sqlplus.append("set feedback off;\n")
        sqlplus.append("@" + file + ";\n")
        sqlplus.append("exit;\n")

        cmd = ''.join(str(statement) for statement in sqlplus)

        with open("sqlplus.pl", "w") as f:
            f.write(cmd)

        call = "sqlplus -S %s/%s@%s @sqlplus.pl" % (usr, pw, svc)

        p = subprocess.Popen(call, shell=True, stdout=subprocess.PIPE)
        stdout, stderr = p.communicate()

        if stdout is not None and len(stdout) > 0:
            print stdout
        if stderr is not None:
            print "Error:" + stderr
            sys.exit(1)
