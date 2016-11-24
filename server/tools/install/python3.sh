#!/bin/sh

yum -y install yum-utils
yum-builddep python

cd /opt
curl -O https://www.python.org/ftp/python/3.5.1/Python-3.5.1.tgz
tar zxvf Python-3.5.1.tgz
cd Python-3.5.1
./configure
make
make install

