#!/bin/sh

# Need IPAddress & DNSServerAddress & Hostname
if [ $# -ne 3 ]; then
  echo "Need IPAddress & DNSServerAddress & Hostname"
  echo "$0 aaa.bbb.ccc.ddd xxx.xxx.xxx.xxx hostname"
  exit 1
fi

yum -y update
yum -y install vim git wget bind-utils traceroute

# SELinux off
setenforce 0
sed -ie 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# install third-party
./third_party.sh

# install python3
./python3.sh

# install auto-update
yum -y install yum-cron
service yum-cron start
chkconfig yum-cron on

# initialize network
./use_static_network.sh $1 $2

# DNS add
./add_dns.sh 8.8.8.8
./add_dns.sh 8.8.4.4

# change hostname
./chg_hostname.sh $3

# reboot
reboot

