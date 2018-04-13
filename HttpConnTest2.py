import urllib.request

try:
		#url = 'https://www.google.com/search?q=python'
		url = 'https://www.google.com.sg'
		# now, with the below headers, we defined ourselves as a simpleton who is
		# still using internet explorer.
		headers = {}
		headers['User-Agent'] = "Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.27 Safari/537.17"
		req = urllib.request.Request(url, headers = headers)
		resp = urllib.request.urlopen(req)
		respData = resp.read()
	
		print ("Response details",respData)
		#saveFile = open('withHeaders.txt','w')
		#saveFile.write(str(respData))
		#saveFile.close()
except urllib.error.HTTPError as e:
		print(e.code)
		print(e.read())