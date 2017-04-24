x=500
y=x
y='foo'
print(x)


x=[500,501,502]
y=x
y[1]=600
print (type(x))
print  ("Value of X:" +str(x).strip('[]'))
print (y)

x=1
if x>0:
	print ("hello")
	print (' x >0 ')
elif x==0:
	print ("X is zero")
else:
	print ("X is -ve")

if x is None:
	print ("X is None")

if x is not None:
	print ("x is not None :" ,x)
	