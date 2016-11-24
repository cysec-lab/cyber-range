#!/bin/sh

touch /etc/test.txt
mv /etc/test.txt /etc/test.conf
echo "xxx" > /etc/test.conf
rm -f /etc/test.conf
