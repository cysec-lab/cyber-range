#!/bin/bash
# クローン後のcentos6の設定を行うスクリプト

# Need new IPAddress
if [ $# -ne 3 ]; then
  echo "Need [VM num] [new IPAddress] [Hostname]"
  echo "$0 [111] [aaa.bbb.ccc.ddd] [hostname]"
  exit 1
fi

VM_NUM=$1
IP_ADDRESS=$2
HOSTNAME=$3
MOUNT_DIR="/mnt/vm$VM_NUM"

RULEFILE="${MOUNT_DIR}/etc/udev/rules.d/70-persistent-net.rules"
ETHFILE="${MOUNT_DIR}/etc/sysconfig/network-scripts/ifcfg-eth0"
NETWORKFILE="${MOUNT_DIR}/etc/sysconfig/network"
CRONFILE="${MOUNT_DIR}/var/spool/cron/root"
CONF_PATH="/etc/pve/qemu-server/${VM_NUM}.conf"

# VMクローン時にProxmoxが新たに生成したMACアドレスをVM内の設定に適応する(新MACアドレスはProxmoxの設定ファイルのみ変更されている．VM内の設定はクローン元と同じ)
NET0=`cat $CONF_PATH | grep -m 1 "net0"`
e1000=${NET0%,*}
HWADDR=${e1000#*e1000=}
sed -i -e "s/ATTR{address}==\".*\",/ATTR{address}==\"${HWADDR,,}\",/g" $RULEFILE
sed -i -e 's/eth1/eth0/g' $RULEFILE

# IPアドレスなどサイバーレンジに利用する設定に変更する
sed -i -e "s/HWADDR=.*$/HWADDR=${HWADDR}/g" $ETHFILE
sed -i -e "s/UUID.*//g" $ETHFILE
sed -i -e "s/IPADDR=.*$/IPADDR=$IP_ADDRESS/g" $ETHFILE
sed -i -e "s/DNS1=.*$/DNS1=${IP_ADDRESS%.*}.1/g" $ETHFILE
sed -i -e "s/GATEWAY=.*$/GATEWAY=${IP_ADDRESS%.*}.1/g" $ETHFILE
sed -i -e "s/BROADCAST=.*$/BROADCAST=${IP_ADDRESS%.*}.255/g" $ETHFILE

# change hostname
sed -i -e "s/HOSTNAME=.*/HOSTNAME=${HOSTNAME}/g" $NETWORKFILE
