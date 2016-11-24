#!/bin/sh

# Need IPAddress & DNSServerAddress & Hostname
if [ $# -ne 3 ]; then
  echo "Need IPAddress & DNSServerAddress & Hostname"
  echo "./setup.sh aaa.bbb.ccc.ddd xxx.xxx.xxx.xxx hostname"
  exit 1
fi

yum -y update

# install third-party
./third_party.sh

# install auto-update
yum -y install yum-cron
service yum-cron start
chkconfig yum-cron on

# initialize network
./use_static_network.sh $1 $2

# change hostname
./chg_hostname.sh $3

# install php7
./php7.sh

# reboot
reboot

