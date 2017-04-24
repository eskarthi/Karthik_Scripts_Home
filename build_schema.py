#!python
import re
import sys
import os

from oracle_helper import query


def getEnv(filename):
    with open(filename) as config:
        content = config.readlines()
        list = [re.sub('[\r\n]', '', x).split('=') for x in content]
        map = {}
        for l in list:
            map[l[0]] = l[1]
        return map


def build_schema(schema, env):
    envMap = getEnv(schema + "." + env + ".config")
    build_list = []

    for path, subdirs, files in os.walk(schema):
        if re.match('(?!.svn)', path):
            for name in files:
                if name == "build_order.txt":
                    build_list.append(path)

    for build in sorted(build_list):
        with open(build + "/build_order.txt") as f:
            content = f.readlines()
            for script in content:
                script = build + "/" + re.sub('[\n\r]', '', script)
                print "Executing " + script
                query(envMap['DB_OWNER'], envMap['DB_OWNER_PASSWORD'], envMap['DB_SERVICE'], script)


if __file__ == "main":
    schema = sys.argv[1]
    env = sys.argv[2]
    build_schema(schema, env)
