import os 
import getopt
import sys
import re

def usage():
	print (sys.argv[1] + "Work5.py <path or foldername>\n")

path=None

def print_directory_contents(sPath):
	for sChild in os.listdir(sPath):                
		sChildPath = os.path.join(sPath,sChild)
		if os.path.isdir(sChildPath):
			print_directory_contents(sChildPath)
		else:
			print(sChildPath)

print_directory_contents(sys.argv[1])
	
#try:
#	options, remainder = getopt.getopt(sys.argv[1:],'o:v', ['output=','verbose','version=',])
#except getopt.GetoptError as err:
#		if path is None:
#			print "No path was provided"
#			usage()
#			sys.exit(1)
#		else :
#			print('ERROR:', err)
#			sys.exit(1)
