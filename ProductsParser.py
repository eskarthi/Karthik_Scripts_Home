#!/usr/bin/python

import sys,getopt
import os,re
import json


def usage():
	print ("Usage :: ProductsParser.py -i InputfileName.json -o OutputfileName.csv\n")

def receiveInputParams(opt,args):
	output_filename = 'default.out'
	input_filename = None
	for opt, args in options:
		if opt in ('-o', '--output'):
			output_filename = args
		elif opt in ('-i', '--input'):
			input_filename = args
		else:
			assert False, "Unhandled option"
			usage()

	if len(args) == 0 and input_filename is None:
			print ("Input filename was not provided")
			usage()
			sys.exit(1)
	else:
		processJsonObject(input_filename,output_filename)

def processJsonObject(input,output):
	print('INPUT   :', input)
	print('OUTPUT  :', output)
	
	writeCsv = []
	print ('id,product_name,supplier')
	writeCsv.append('id,product_name,supplier \n')
	with open(input,'rb') as filename :
			jsonToPython = json.load(filename)
			print ("Class type of filename::",type(filename))
			for data in jsonToPython["entry"]:
				#writeCsv.append(data['_id']['$oid']+","+data['product_name']+","+data['supplier']+"\n")
				#print (data['_id']['$oid']+","+data['product_name']+","+data['supplier'])
				#print (data['entry']['name']+","+data['entry']['id']+","+data['entry']['updated'])
				print (data["name"]+","+data["id"]+","+data["updated"])
				
			cmd = ''.join(str(statement) for statement in writeCsv)
				
			with open(output, "w") as fout:
				fout.write(cmd)

if __name__ == "__main__":
	try:
		options, args = getopt.getopt(sys.argv[1:], "i:o:" ,["input=","output="])
		receiveInputParams(options,args)
	except getopt.GetoptError as err:
		print( "Error unhandled :",err)
		sys.exit(1)
		

 