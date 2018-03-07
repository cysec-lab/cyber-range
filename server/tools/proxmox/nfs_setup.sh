#!/bin/bash
#TODO ファイルのディレクトリがきちんと分かっていない
# テンプレートIPアドレス決め打ち

if [ $# -ne 3 ]; then
  echo "Need [VM num] [IPAddress] [PC Type]"
  echo "$0 [100] [aaa.bbb.ccc.ddd] [client]"
  exit 1
fi

VM_NUM=$1
IP=$2
PC_TYPE=$3
DIR_PATH="/mnt/vm$VM_NUM"

if [ $PC_TYPE = 'client' ]; then
    TEMPLATE_SERVER_IP='192.168.100.144'
    SERVER_IP=${IP##*.}
    SERVER_IP=${SERVER_IP:0:1}4
    sed -i -e "s/$TEMPLATE_SERVER_IP/${IP%.*}.$SERVER_IP/g" "$DIR_PATH/etc/fstab"
    #echo -e "${IP%.*}.$SERVER_IP:/var/www/html\t/home/workspace\tnfs\trsize=8192,wsize=8192,nosuid,hard,intr\t0 0" >> /etc/fstab

# 割り当てがおかしい
elif [ $PC_TYPE = 'server' ]; then
    TEMPLATE_IP='192.168.0'
    sed -i -e "s/$TEMPLATE_IP/${IP%.*}/g" "$DIR_PATH/etc/exports"
    #echo -e "/var/www/html ${IP%.*}.0/24(rw,sync,no_root_squash)" >> /etc/exports
else
    echo "Please (client or server) args"
    exit 1
fi
