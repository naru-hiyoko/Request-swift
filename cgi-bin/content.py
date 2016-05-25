#!//usr/local/bin/python2.7
# encoding: utf-8
import cgi


print "Content-Type: text/html\n\n"

print """
<meta charset='utf-8'>
<html>
<head>
<title> TEST </title>
</head>
<body>
test
</body>
</html>
"""

files = cgi.FieldStorage()
for f in files.keys():
    print f


print 'ok.'

