#!/usr/bin/python

import sys
	# Function definition is here
def printme(str):
	print (str)
	return;
		
def printme2(str1,str2):
	print (str1,str2)
	return;
	
def reviewzip():
	list1 = ['A','B','C']
	list2 = [10,20,30]
	printme("Calling ..")
	result = zip(list1,list2)
	resultList = list(result)
	printme2("resultlist ::", resultList) # results in a list of tuples say [('A',10),('B',20),('C',30)]

	# Converting to set
	result = zip(list1,list2)
	resultSet = set(result)
	printme2("resultset ::", resultSet)
	
printme("Initiating ")
reviewzip()