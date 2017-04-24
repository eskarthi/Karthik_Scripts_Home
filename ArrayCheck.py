import os
print (os.getpid())

class Person(object):
	def __init__(self,first,last,age):
		self.first=first
		self.last=last
		self.age=age
		
	def full_name(self):
		return self.first +'###'+self.last
		
person= Person ('karthik','Shanmugam','36')
print (person.first)
print (person.last)
print (person.full_name())
print (person.age)
