import urllib.request

req = urllib.request.Request('http://www.python.org')
#req = urllib.request.Request('https://localhost:8089/services/properties?output_mode=json')
response = urllib.request.urlopen(req)
the_page = response.read()

print ("Page details",the_page)

