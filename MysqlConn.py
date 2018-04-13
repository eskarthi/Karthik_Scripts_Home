from mysql.connector import (connection,errorcode,Error)

try:
	db = connection.MySQLConnection(user="root",password="MyNewPass@123", host="192.168.1.119",database="Information_schema")
	# prepare a cursor object using cursor() method
	cursor = db.cursor()

	# execute SQL query using execute() method.
	cursor.execute("SELECT VERSION()")

	# Fetch a single row using fetchone() method.
	data = cursor.fetchone()
	print ("Database version : %s " % data)

	# disconnect from server
	db.close()
except Error as err:
	if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
		print("Something is wrong with your user name or password")
	elif err.errno == errorcode.ER_BAD_DB_ERROR:
		print("Database does not exist")
	else:
		print("Program Error:",err)
else:
	db.close()