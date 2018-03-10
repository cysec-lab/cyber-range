#!/usr/bin/env python3
# coding: UTF-8

import struct

Address = "216.58.197.14"

format = b''
address_a = Address.split(".")
for address in address_a:
    print (int(address))
    print (int(address).to_bytes(1, 'big'))
    format += int(address).to_bytes(1, 'big')
    print (format)

