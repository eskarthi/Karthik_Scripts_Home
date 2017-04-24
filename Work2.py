i=0
total=0
while i<100:
	total +=i
	i=i+1
print (total)

plays =set(['Beautiful','Life','Love','Others'])

for play in plays:
	print ('***perform',play)
	
while plays:
	#play=plays.pop()
	#print ('perform' , play )
	print ('perform ...pop' , plays.pop())

