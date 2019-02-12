#!/bin/sh

yum -y install https://centos6.iuscommunity.org/ius-release.rpm
yum install -y python36*

ln -s /usr/bin/python3.6 /usr/bin/python3
ln -s /usr/bin/pip3.6 /usr/bin/pip3
