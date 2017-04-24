#!python
import getopt
import sys
import re

from build_schema import build_schema, getEnv
from oracle_helper import query


def usage():
    print sys.argv[0] + " [-h|--help] [-b|--rebuild] [-e str|-environment=str]\n";


try:
    opts, args = getopt.getopt(sys.argv[1:], "hbe:v", ["help", "rebuild", "environment="])
except getopt.GetoptError as err:
    print str(err)
    usage()
    sys.exit(1)

rebuild = None
environment = None

for o, a in opts:
    if o in ("-h", "--help"):
        usage()
        sys.exit()
    elif o in ("-b", "--rebuild"):
        rebuild = True
    elif o in ("-e", "--environment"):
        environment = a
    else:
        assert False, "unhandled option"

if environment is None:
    print "No enviroment was provided"
    usage()
    sys.exit(1)

if rebuild:
    envMap = getEnv("XODS_BUILD." + environment + ".config")
    print "Executing 00_drop_schemas.pl"
    query(envMap['DB_OWNER'], envMap['DB_OWNER_PASSWORD'], envMap['DB_SERVICE'], "00_drop_schemas.pl")
    print "Executing 01_create_schemas.pl"
    query(envMap['DB_OWNER'], envMap['DB_OWNER_PASSWORD'], envMap['DB_SERVICE'], "01_create_schemas.pl")

with open("schema." + environment + ".lst") as f:
    for schema in f.readlines():
        schema = re.sub('[\n\r]', '', schema)
        if schema.split():
            build_schema(schema, environment)