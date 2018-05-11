#!/usr/bin/python
# encoding: utf-8
'''
HostValidator -- Validate all the hosts listed in windows\etc hosts file

It defines classes_and_methods

@author:     Karthik

@copyright:  2018 Prudential Singapore Services. All rights reserved.

@license:    Prudential Singapore Services

@contact:    karthik.es@prudential.com.sg
@deffield    updated: 08-May-2018
'''

import sys
import os 
import re 
import getopt
import requests, json
import warnings

__version__ = 0.1
__date__ = '24-04-2018'
__updated__ = '08-05-2018'
warnings.filterwarnings("ignore")

writeCsv = []

	
def usage():
	print ("Usage :: HostValidator.py -i InputfileName -o OutputfileName.csv\n")


def receiveInputParams(opt, args):
	output_filename = 'default_out.csv'
	input_filename = None   
	
	try:
		for opt, args in options:
			if opt in ('-o', '--output'):
				output_filename = args
			elif opt in ('-i', '--input'):
				input_filename = args
			else:
				assert False, "Unhandled option"
				usage()
	
		if len(args) == 0 or input_filename is None:
				input_filename = 'C:\Windows\System32\drivers\etc\hosts'
				print ("Input filename was not provided, taking default file", input_filename)
				processHostObject(input_filename, output_filename)
		else:
			processHostObject(input_filename, output_filename)

	except Exception as e:
			program_name = os.path.basename(sys.argv[0])
			sys.stderr.write(program_name + ": " + repr(e) + "\n")
			sys.stderr.write(e)
			return 2

		
def processHostObject(input_file, output_file):
	
	print('INPUT  :', input_file)
	print('OUTPUT  :', output_file + "\n")
	
	host_file = open(input_file)
	
	writeCsv.append('Hostname,HttpCode,HttpMessage, Target ServerType \n')
	print("Hostname,HttpCode,HttpMessage,Target ServerType")
	for line in host_file:
			# print (line)
			regex = re.match("^#\t\d+", line)
			if regex is not None:
				write_result (line.strip().split("\t")[3:])
			else:
				regex = re.search("^\t\d+", line)
				if regex is not None: 
					write_result (line.strip().split("\t")[2:])	
	
	cmd = ''.join(str(statement) for statement in writeCsv)
	
	with open(output_file, "w") as file_out:
		file_out.write(cmd)
		
						
def write_result(host_line):
		if len(host_line) > 0:
			connStatus = check_httpCon(host_line[0])  # # Message as response Object
			
			if (connStatus is None) :
				print (host_line[0] + "," + "Connection Error" + "," + "Max retries exceeded. Connection failed because connected host has failed to respond" + "," + "None")
				writeCsv.append(host_line[0] + "," + "Connection Error" + "," + "Max retries exceeded. Connection failed because connected host has failed to respond" + "," + "None \n")
			else :
				receivedMsg = connStatus.text  # # Message converted to String Object
				if (receivedMsg.find('httpCode') != -1):
					respText = json.loads(receivedMsg)
					print (host_line[0] + "," + respText['httpCode'] + "," + respText['httpMessage'] + "," + check_cloudfare(connStatus))
					writeCsv.append(host_line[0] + "," + respText['httpCode'] + "," + respText['httpMessage'] + "," + check_cloudfare(connStatus) + "\n")
				else:
					if (receivedMsg.find("title") != -1):
						print (host_line[0] + "," + str(connStatus.status_code) + "," + extract_httpMessage(receivedMsg) + "," + check_cloudfare(connStatus))
						writeCsv.append(host_line[0] + "," + str(connStatus.status_code) + "," + extract_httpMessage(receivedMsg) + "," + check_cloudfare(connStatus) + "\n")
					else:
						print (host_line[0] + "," + str(connStatus.status_code) + "," + str(connStatus.content.strip()[0:73]) + "," + check_cloudfare(connStatus))
						writeCsv.append (host_line[0] + "," + str(connStatus.status_code) + "," + str(connStatus.content.strip()[0:73]) + "," + check_cloudfare(connStatus) + "\n")
					
		
def check_cloudfare(resp_header):
		if (resp_header.headers.get("server") is not None):
			return resp_header.headers.get("server") 
		else:
			return "Unknown"
			
# # def is_domestic(line):
# # 		return line.endswith('.com') or line.endswith('.net') or line.endswith('.sg') or line.endswith('.tw') or line.endswith('.id')


def check_httpCon(url):
	response = None
	try:
		response = requests.get("https://" + url, verify=False, timeout=50)
		response.raise_for_status()
		
	except requests.exceptions.RequestException :
		pass

	if (response is None):
		return None
	else: 
		return response


def extract_httpMessage(response):
			start = response.find ("title>") + 6
			end = response.find ("/title>") - 1
			return response [start:end]

		
if __name__ == "__main__":
	try:
		options, args = getopt.getopt(sys.argv[1:], "i:o:" , ["input=", "output="])
		receiveInputParams(options, args)
	except getopt.GetoptError as err:
		print("Unknown parameter -:", err)
		sys.exit(1)
