#!/usr/bin/env python3
# coding: UTF-8

import sys
import socket
import struct

argvs = sys.argv
argc = len(argvs)

# TODO considering argvs
if argc != 2:
    print ('Usage: python %s (DNS Server IP Adress) #(Request URL)' % argvs[0])
    sys.exit(1)

DNS = argvs[1]  # DNS Server Address
URL = "web.server.cysec.local" #argvs[2]  # Request URL
PORT = 53       # DNS Port
LEN = 512       # maxLen bits

def convert_binary_to_IPstr(binary):
    ip = str(int.from_bytes(binary, 'big'))
    return ip

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

# Generate DNS Request
# for a server status request, we only need a header
# header format is described in RFC 1035
def header_request():
    id      = 1

    qr      = 0 << 15 # qr = 0      => query (request)
    opcode  = 0 << 11 # opcode = 0  => standard request
    aa      = 0 << 10
    tc      = 0 << 9
    rd      = 1 << 8
    ra      = 0 << 7
    z       = 0 << 6
    ad      = 0 << 5
    cd      = 0 << 4
    rcode   = 0 << 0

    qdcount = 1
    ancount = 0
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

def main():
    # create header
    header = header_request()

    # create question
    question = question_request()

    # create DNS request message
    req = header + question
    
    # display DNS request message
    print (" Request:  ", end='')
    print (req)

    # create socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.connect((DNS,PORT))

    # send the query
    sock.send(req)

    # receive response
    data = sock.recv(LEN)

    # display received data
    # data[0] => received data
    print (" Response: ", end='')
    print (data)

    # display response code
    # lower 4 bytes of 4th octet in received data is the response code
    print (" RCODE:    ", end='')
    split_format = str(len(data)) + "c"
    rcode_b = (struct.unpack(split_format, data)[3])
    print (int.from_bytes(rcode_b, 'big') % (1 << 4)) 


    # display response IP Address
    split_b = (struct.unpack(split_format, data))
    
    question_head = 12
    next = int.from_bytes(split_b[question_head], 'big')
    while next != 0:
        question_head += next+1
        next = int.from_bytes(split_b[question_head], 'big')

    question_head += 1 # move to Type
    question_head += 4 # move Answer section

    next = int.from_bytes(split_b[question_head], 'big')
    while next != 0:
        if next == 192:
            question_head += 2
            break
        question_head += next+1
        next = int.from_bytes(split_b[question_head], 'big')
    
    question_head += 10 # move to RDATA

    ip1 = convert_binary_to_IPstr(split_b[question_head])
    ip2 = convert_binary_to_IPstr(split_b[question_head+1])
    ip3 = convert_binary_to_IPstr(split_b[question_head+2])
    ip4 = convert_binary_to_IPstr(split_b[question_head+3])
    print (ip1+'.'+ip2+'.'+ip3+'.'+ip4)
    
    sock.close()

if __name__ == '__main__':
    main()

