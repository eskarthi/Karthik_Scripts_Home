from sys import argv

script, filename = argv

#filename = input('Enter a valid filename : ')

txt = open(filename)

print ("Here's your file %r:" %filename)
print (txt.read())

print ("Type the filename again:" %filename)

file_again = raw_input("> ")
txt_again = open(file_again)

print (txt_again.read())