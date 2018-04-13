import urllib.parse
import urllib.request
import urllib.response
import ssl,json

username='admin'
password='admin'
top_level_url = "https://localhost:8089/services/properties?output_mode=json"

# create an authorization handler
p = urllib.request.HTTPPasswordMgrWithDefaultRealm()
p.add_password(None, top_level_url, username, password)

auth_handler = urllib.request.HTTPBasicAuthHandler(p)

context = ssl.create_default_context()
context.check_hostname = False
context.verify_mode = ssl.CERT_NONE

opener = urllib.request.build_opener(auth_handler ,urllib.request.HTTPSHandler(context=context))

urllib.request.install_opener(opener)

try:
	result = opener.open(top_level_url)
	messages = result.read().decode('utf-8')
	json_response = json.loads(messages)

	for data in json_response["entry"]:
		print ("-"+data["name"]+","+data["id"]+","+data["updated"])
		
	#with open("prop_output.csv", "w") as fout:
	#	fout.write(messages)

except IOError as e:
    print (e)