# encoding: utf-8

import requests

url = "http://localhost:8000/cgi-bin/content.py"
"""
f = open('sample.jpg', 'rb')
image = f.read()
f.close()
"""

ret = requests.post(url, files = {
    'test' : 'hello'
    # 'sample.jpg' : image
})
print ret.content

