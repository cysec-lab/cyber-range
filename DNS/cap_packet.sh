#!/bin/sh

tcpdump -s 65535 -w out.pcapng port 53
