#!/bin/sh

yum -y install https://centos6.iuscommunity.org/ius-release.rpm
yum install -y python35*

ln -s /usr/bin/python3.5 /usr/bin/python3
ln -s /usr/bin/pip3.5 /usr/bin/pip3

#yum -y install yum-utils
#yum-builddep python
#
#cd /opt
#curl -O https://www.python.org/ftp/python/3.5.1/Python-3.5.1.tgz
#tar zxvf Python-3.5.1.tgz
#cd Python-3.5.1
#./configure
#make
#make install

