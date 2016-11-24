#!/bin/sh

filename='/etc/sysconfig/network-scripts/ifcfg-eth0'
sed -i -e "s/BOOTPROTO=dhcp/BOOTPROTO=static/g" ${filename}
sed -i -e "s/DEFROUTE=yes//g" ${filename}
sed -i -e "s/IPV4_FAILURE_FATAL=yes//g" ${filename}
sed -i -e "s/IPV6INIT=no//g" ${filename}
sed -i -e "s/PEERDNS=yes//g" ${filename}
sed -i -e "s/PEERROUTES=yes//g" ${filename}
sed -i -e "/^$/d" ${filename}

echo "IPADDR=$1" >> ${filename}
echo "DNS1=$2" >> ${filename}
echo "NETMASK=255.255.255.0" >> ${filename}
echo "GATEWAY=$3" >> ${filename}
echo "BROADCAST=${1%.*}.255" >> ${filename}

`echo 'service network restart'`

