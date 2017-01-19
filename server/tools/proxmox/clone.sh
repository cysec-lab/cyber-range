#!/bin/bash

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
NET_UUID_PATH="/etc/pve/nodes/proxmox/qemu-server/${VM_NUM}.conf"

OUTFILE="$MOUNT_DIR/root/test.txt"
touch $OUTFILE

cat $ETHFILE >> $OUTFILE
cat $RULEFILE >> $OUTFILE

#while read line
#do
#  case "$line" in
#    *0x8086* ) doc=${line}"\n" ;;
#    *eth0* ) conf=${line} ;;
#    #*eth1* ) conf=${line} ;;
#  esac
#done < ${RULEFILE}

NET0=`cat $NET_UUID_PATH | grep "net0"`
VIRTIO=${NET0%,*}
NET_UUID=${VIRTIO#*virtio=}
sed -i -e "s/ATTR{address}==\".*\",/ATTR{address}==\"${NET_UUID,,}\",/g" $RULEFILE

# 改行文字の問題解決
#doc=${doc}${conf}
#echo ${doc%\\n} | sed -e 's/\\n/\n/g' -e 's/eth1/eth0/g' > ${RULEFILE}


#attr=${conf#*ATTR{address\}==\"}
#sed -i -e "s/HWADDR=.*$/HWADDR=${attr%%\"*}/g" $ETHFILE
sed -i -e "s/HWADDR=.*$/HWADDR=${NET_UUID}/g" $ETHFILE

sed -i -e "s/UUID.*//g" $ETHFILE
sed -i -e "s/IPADDR=.*$/IPADDR=$IP_ADDRESS/g" $ETHFILE
sed -i -e "s/DNS1=.*$/DNS1=${IP_ADDRESS%.*}.1/g" $ETHFILE
sed -i -e "s/GATEWAY=.*$/GATEWAY=${IP_ADDRESS%.*}.1/g" $ETHFILE
sed -i -e "s/BROADCAST=.*$/BROADCAST=${IP_ADDRESS%.*}.255/g" $ETHFILE

#cat $attr >> $MOUNT_DIR/root/test.txt
cat $ETHFILE >> $OUTFILE
cat $RULEFILE >> $OUTFILE

FILENAME="${MOUNT_DIR}/etc/sysconfig/network"
sed -i -e "s/HOSTNAME=.*/HOSTNAME=${HOSTNAME}/g" ${FILENAME}

