#!/bin/sh

yum -y install epel-release wget
wget http://dl.fedoraproject.org/pub/epel/6/i386/dsniff-2.4-0.17.b1.el6.i686.rpm
yum -y install dsniff-2.4-0.17.b1.el6.i686.rpm 
yum -y install dsniff
