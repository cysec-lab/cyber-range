#!/bin/bash

# Need new IPAddress
if [ $# -ne 3 ]; then
  echo "Need new [IPAddress] and [Hostname] [VM num]"
  echo "$0 [aaa.bbb.ccc.ddd] [hostname] [111]"
  exit 1
fi

#VM_NUM=`echo $2 | sed -e "s/[^0-9]*//"`
VM_NUM=$3
MOUNT_DIR="/mnt/vm$VM_NUM"

RULEFILE="$MOUNT_DIR/etc/udev/rules.d/70-persistent-net.rules"
ETHFILE="$MOUNT_DIR/etc/sysconfig/network-scripts/ifcfg-eth0"

while read line
do
  case "$line" in
    *0x8086* ) doc=${line}"\n" ;;
    *eth1* ) conf=${line} ;;
  esac
done < ${RULEFILE}


# 改行文字の問題解決
doc=${doc}${conf}
echo ${doc%\\n} | sed -e 's/\\n/\n/g' -e 's/eth1/eth0/g' > ${RULEFILE}


attr=${conf#*ATTR{address\}==\"}
sed -i -e "s/HWADDR=.*$/HWADDR=${attr%%\"*}/g" $ETHFILE

sed -i -e "s/IPADDR=.*$/IPADDR=$1/g" $ETHFILE
sed -i -e "s/DNS1=.*$/DNS1=${1%.*}.1/g" $ETHFILE
sed -i -e "s/GATEWAY=.*$/GATEWAY=${1%.*}.1/g" $ETHFILE
sed -i -e "s/BROADCAST=.*$/BROADCAST=${1%.*}.255/g" $ETHFILE


FILENAME="$MOUNT_DIR/etc/sysconfig/network"
sed -i -e "s/HOSTNAME=.*/HOSTNAME=$2/g" ${FILENAME}

#service network restart

#qm reboot $VM_NUM
