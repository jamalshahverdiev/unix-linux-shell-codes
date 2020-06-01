#!/usr/bin/env python3
import datetime

print(datetime.datetime.now())
with open('source.txt', 'r') as file: 
    data = file.readlines()

ipdict = {}

for line in data:
    if line in ipdict.keys():
        ipdict[line] = ipdict[line] + 1
    else:
        ipdict[line] = 1

for key in ipdict:
    print(key.rstrip(),' : ',ipdict[key])

print(datetime.datetime.now())
