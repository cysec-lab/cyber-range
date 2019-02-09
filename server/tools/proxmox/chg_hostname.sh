#!/bin/sh
#TODO: installのところに同じものがある？

# Hostnameの引数が必要
if [ $# -ne 1 ]; then
  echo "Need Hostname"
  echo "$0 Hostname"
  exit 1
fi

FILENAME='/etc/sysconfig/network'
sed -i -e "s/HOSTNAME=.*/HOSTNAME=$1/g" ${FILENAME}

service network restart
