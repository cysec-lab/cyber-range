#!/bin/sh

# Need new IPAddress
if [ $# -ne 2 ]; then
  echo "Need new IPAddress and Hostname"
  echo "$0 [aaa.bbb.ccc.ddd] [hostname]"
  exit 1
fi

RULEFILE='/etc/udev/rules.d/70-persistent-net.rules'
ETHFILE='/etc/sysconfig/network-scripts/ifcfg-eth0'

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

./chg_hostname.sh $2

reboot

