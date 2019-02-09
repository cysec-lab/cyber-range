#!/bin/sh

# Hostnameの引数が必要
if [ $# -ne 2 ]; then
  echo "何番目のDNSホストか、DNSのIPアドレスの2個の引数が必要です"
  echo "example:"
  echo "$0 1 aaa.bbb.ccc.ddd"
  exit 1
fi

FILENAME='/etc/sysconfig/network-scripts/ifcfg-eth0'
sed -i -e "s/DNS$1=.*$/DNS$1=$2/g" ${FILENAME}

service network restart

