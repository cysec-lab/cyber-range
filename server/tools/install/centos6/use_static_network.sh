#!/bin/sh

# IPアドレスとDNSアドレスの引数が必要
if [ $# -ne 2 ]; then
  echo "Need IPAddress and DNSAddress"
  echo "./use_static_network.sh IPAddress DNSAddress"
  exit 1
fi

DOC=""

FILENAME='/etc/sysconfig/network-scripts/ifcfg-eth0'

while read line 
do
  case "$line" in
    DEVICE* ) DOC=${DOC}${line}"\n" ;;
    TYPE* ) DOC=${DOC}${line}"\n" ;;
    UUID* ) DOC=${DOC}${line}"\n" ;;
    ONBOOT* ) DOC=${DOC}${line}"\n" ;;
    NM_CONTROLLED*) DOC=${DOC}${line}"\n" ;;
    NAME*) DOC=${DOC}${line}"\n" ;;
    HWADDR*) DOC=${DOC}${line}"\n" ;;
  esac
done < ${FILENAME}

DOC=${DOC}"BOOTPROTO=static\n"
DOC=${DOC}"IPADDR=$1\n"
DOC=${DOC}"DNS1=$2\n"
DOC=${DOC}"NETMASK=255.255.255.0\n"
DOC=${DOC}"GATEWAY=${1%.*}.1\n"
DOC=${DOC}"BROADCAST=${1%.*}.255\n"

# 改行文字の問題解決
echo ${DOC%\\n} | sed -e 's/\\n/\n/g' > ${FILENAME}

service network restart

