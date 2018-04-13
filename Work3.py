#from sys import argv
import sys
import os.path
import re


# Function definition is here
def printme(str):
	print (str)
	return;
	
def readandprint (file):
	count_lines=0
	for line in file:
		
		count_lines += 1
		#test1="Meaning:Salutations again and again to the Devi (Goddess) who resides in all beings in the form of illusion."
		regex = re.match ( "^MEANING?",line,re.I|re.M|re.U)
		if regex is not None:
			printme ("Each line..." +line)
			#printme ("contains ="+regex.group())
		#else:
		#	printme ("regex is None")

		
		print ("number of lines:", count_lines)
		
		#Eight_letter_word = regex.findall(line);
		#print ("Matching lines.. ",Eight_letter_word)
		
#script, filename = argv
# Below commands used to read the filename from the console...
filename = input('Enter a filename : ')

try:
	file=open(filename,"r")
	# printing each line using for loop.
	readandprint(file)

	## below syntax will print contents of the file at one go.
	#test=file.read()
	#printme (test)
	
	print (".... finished reading filename :",filename)
	file.close()
except IOError as exc:
	printme ("file not exist",filename)		
	