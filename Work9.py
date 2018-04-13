#!python
import subprocess
import sys
import os.path


def query(file):
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
			
query (sys.argv[1])
