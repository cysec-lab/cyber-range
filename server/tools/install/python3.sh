#!/bin/sh

yum -y install https://centos6.iuscommunity.org/ius-release.rpm
yum install -y python35*

ln -s /usr/bin/python3.5 /usr/bin/python3
ln -s /usr/bin/pip3.5 /usr/bin/pip3
