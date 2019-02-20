#!/bin/sh
#TODO: インストール出来ていない
# wgetで落ちてきていない

john_version='1.7.9-1' # ここのバージョンを変更するとインストールされるバージョンが変わる

yum -y install wget
result=`lscpu | grep 'Architecture' | grep 'x86_64'`
if [ ${#result} -ne 0 ]; then
    # 64bit
    linux_version='x86_64'
else
    # 32bit
    linux_version='i686'
fi
john_rpm="john-${john_version}.el6.rf.${linux_version}.rpm"

#rpm -import http://ftp.riken.jp/Linux/dag/RPM-GPG-KEY.dag.txt
wget http://pkgs.repoforge.org/rpmforge-release/$john_rpm
wget https://centos.pkgs.org/6/repoforge-${linux_version}/$john_rpm
rpm -ivh $john_rpm
yum -y install john # No package john available
