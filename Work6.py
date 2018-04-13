import getopt
import sys

version = '1.0'
verbose = False
output_filename = 'default.out'



try:
	options, args = getopt.getopt(sys.argv[1:], "vo:a:" ,["output=","version="])
except getopt.GetoptError as err:
	print('ERROR:', err)
	sys.exit(1)

print('ARGV      :', sys.argv[1:])
print('OPTIONS   :', options)

for opt, arg in options:
	print ("value in options:", opt +" arguments:", arg)
	if opt in ('-o', '--output'):
		output_filename = arg
	elif opt in ('-v', '--verbose'):
		verbose = True
#	elif opt == '--version':
	elif opt in ('-a', '--version'):
		version = arg
	else:
		assert False, "unhandled option"

print('VERSION   :', version)
print('VERBOSE   :', verbose)
print('OUTPUT    :', output_filename)
print('REMAINING :', args)