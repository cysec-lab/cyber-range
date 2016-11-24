#!/usr/bin/env python3
# coding: UTF-8

import socket
import time

def main():
    host = '192.168.0.11'
    port = 53
    count = 0

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    while True:
        message = ('Hello World : {0}'.format(count).encode('utf-8'))
        print (message)
        sock.sendto(message, (host, port))
        count += 1
        print (sock.recv(4096))
        time.sleep(1)

if __name__ == '__main__':
    main()


