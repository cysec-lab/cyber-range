#!/usr/bin/env python3
# coding: UTF-8
# Refere:http://qiita.com/dhomma/items/7d058856ed46354920d7

import sys
import socket
import struct

argvs = sys.argv
argc = len(argvs)

if argc != 2:
    print ('Usage: python %s (DNS Server IP Adress)' % argvs[0])
    sys.exit(1)

DNS = argvs[1]  # DNS Server Address
PORT = 53       # DNS Port
LEN = 512       # maxLen bits

def convert_16_bits(number):
    return number.to_bytes(2, 'big')

# Generate DNS Request
# for a server status request, we only need a header
# header format is described in RFC 1035
def dns_request():
    id      = 1 
    
    qr      = 0 << 15 # qr = 0      => query (request)
    opcode  = 2 << 11 # opcode = 2  => server status request
    aa      = 0 << 10
    tc      = 0 << 9
    rd      = 0 << 8
    ra      = 0 << 7
    z       = 0 << 6
    ad      = 0 << 5
    cd      = 0 << 4
    rcode   = 0 << 0

    qdcount = 0
    ancount = 0
    nscount = 0
    arcount = 0

    f1 = convert_16_bits(id)
    f2 = convert_16_bits(qr + opcode + aa + tc + rd + ra + z + ad + cd + rcode) 
    f3 = convert_16_bits(qdcount)
    f4 = convert_16_bits(ancount)
    f5 = convert_16_bits(nscount)
    f6 = convert_16_bits(arcount)

    # convets 16bit bits array
    header = f1 + f2 + f3 + f4 + f5 + f6

    return header

def main():
    # create DNS request message
    req = dns_request()
    
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
    # lower 4 bytes of the 4th octet in received data is the response code
    print (" RCODE:    ", end='')
    rcode_format = str(len(data)) + "c"
    rcode_b = (struct.unpack(rcode_format, data)[3])
    print (int.from_bytes(rcode_b, 'big') % (1 << 4))

if __name__ == '__main__':
    main()

