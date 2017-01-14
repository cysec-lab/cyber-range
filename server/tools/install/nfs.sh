#!/bin/bash

if [ $# -ne 1 ]; then
    echo "[PC name] need  (client or server)"
    echo "./nfs.sh [client]"
    exit 1
fi

addr=`ifconfig | grep 192`
IP=${addr#*addr:}
IP=`echo $IP | awk '{print $1}'`

yum -y install rpcbind nfs-utils nfs-util-lib

if [ $1 = 'client' ]; then
    SERVER_IP=${IP##*.}
    SERVER_IP=${SERVER_IP:0:2}4
    mkdir /home/workspace
    #mount -t nfs ${IP%.*}.$SERVER_IP:/var/www/html /home/workspace
    echo -e "${IP%.*}.$SERVER_IP:/var/www/html\t/home/workspace\tnfs\trsize=8192,wsize=8192,nosuid,hard,intr\t0 0" >> /etc/fstab


elif [ $1 = 'server' ]; then
    echo "/var/www/html ${IP%.*}.0/24(rw,sync,no_root_squash)" >> /etc/exports
    exportfs -ra

    service rpcbind start
    service nfslock start
    service nfs start

    INSERT_LINE='-A INPUT -m state --state NEW -m tcp -p tcp --dport 2049 -j ACCEPT\n-A INPUT -m state --state NEW -m udp -p udp --dport 2049 -j ACCEPT\n-A INPUT -m state --state NEW -m tcp -p tcp --dport 111 -j ACCEPT\n-A INPUT -m state --state NEW -m udp -p udp --dport 111 -j ACCEPT'

    IPTABELS='/etc/sysconfig/iptables'
    sed -i -e "/22/a $INSERT_LINE" $IPTABELS
    service iptables restart
    chkconfig nfs on

else
    echo "Please (client or server) args"
    exit 1
fi

