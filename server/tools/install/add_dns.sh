#!/bin/sh

# Hostnameの引数が必要
if [ $# -ne 1 ]; then
  echo "Need add DNS-IP-Address"
  echo "./add_dns aaa.bbb.ccc.ddd"
  exit 1
fi

FILENAME='/etc/sysconfig/network-scripts/ifcfg-eth0'
DNS=`cat ${FILENAME} | grep DNS`
IP=`echo ${DNS##*=}`
COUNT=`cat ${FILENAME} | grep DNS | wc -w`
NEXT=$(( COUNT + 1 ))

if [ $COUNT -ne 0 ]; then
  sed -i -e "s/DNS$COUNT=.*$/DNS$COUNT=$IP\nDNS$NEXT=$1/g" ${FILENAME}
else
  echo "DNS1=$1" >> ${FILENAME}
fi
  
service network restart

