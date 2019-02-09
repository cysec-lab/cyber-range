#!/bin/sh
#TODO: インストール出来ていない

#rpm -import http://ftp.riken.jp/Linux/dag/RPM-GPG-KEY.dag.txt
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
rpm -ivh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
yum -y install john # No package john available
