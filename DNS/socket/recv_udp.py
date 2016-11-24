#!/usr/bin/env python3
# coding: UTF-8

import socket

def main():
    # get My Ip Address
    # socket.gethostbyname(socket.gethostname())
    host = '' # Bind to all interfaces
    port = 53
    bufsize = 4096

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((host, port))
    while True:
        data, address = sock.recvfrom(bufsize)
        sock.sendto("recvd:" + data, address)

if __name__ == '__main__':
    main()


