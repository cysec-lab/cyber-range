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


INITFILE='/etc/inittab'
sed -i -e 's/id:3:initdefault:/id:5:initdefault:/g' $INITFILE

HOSTNAME=$2

useradd 'client'
#useradd ${HOSTNAME}


yum -y install expect
expect -c "
set timeout 5
spawn passwd client
expect \"New password:\"
send \"client\n\"
expect \"Retype new password:\"
send \"client\n\"
interact
"
#yum -y install expect
#expect -c "
#set timeout 5
#spawn passwd ${HOSTNAME}
#expect \"New password:\"
#send \"${HOSTNAME}\n\"
#expect \"Retype new password:\"
#send \"${HOSTNAME}\n\"
#interact
#"

#yum -y install gedit

./chg_hostname.sh $HOSTNAME

reboot

