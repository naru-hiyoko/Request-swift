#!/usr/local/bin/python2.7
# encoding: utf-8

import BaseHTTPServer
import CGIHTTPServer

port = 8000
address = 'localhost'

BaseHTTPServer.HTTPServer((address, port), CGIHTTPServer.CGIHTTPRequestHandler).serve_forever()
