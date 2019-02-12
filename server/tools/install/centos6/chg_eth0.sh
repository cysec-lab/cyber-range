#!/bin/sh

# Hostnameの引数が必要
if [ $# -ne 1 ]; then
  echo "eth0のIPアドレスの引数が1個だけ必要です"
  echo "example:"
  echo "$0 aaa.bbb.ccc.ddd"
  exit 1
fi

FILENAME='/etc/sysconfig/network-scripts/ifcfg-eth0'
sed -i -e "s/IPADDR=.*$/IPADDR=$1/g" ${FILENAME}

service network restart

