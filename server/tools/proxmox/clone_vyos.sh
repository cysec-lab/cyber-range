#!/bin/bash
#TODO: テンプレートVMを指定する
# クローン後のvyosの設定を行うスクリプト


if [ $# -ne 3 ]; then
  echo "Need new [VM num] [VYOS_NETWORK_BRIDGE] [GROUP_NETWORK_BRIDGE]"
  echo "example:"
  echo "$0 111 1 132"
  exit 1
fi

VM_NUM=$1
VYOS_NETWORK_BRIDGE=$2
GROUP_NETWORK_BRIDGE=$3

VM_CONF_FILE="/etc/pve/qemu-server/${VM_NUM}.conf"

VYOS_NETRORK_MAC_ADDRESS=`cat $VM_CONF_FILE | grep net0`
# MACアドレスの前後の部分を削除
VYOS_NETRORK_MAC_ADDRESS=${VYOS_NETRORK_MAC_ADDRESS%,*}
VYOS_NETRORK_MAC_ADDRESS=${VYOS_NETRORK_MAC_ADDRESS#*=}

GROUP_NETRORK_MAC_ADDRESS=`cat $VM_CONF_FILE | grep net1`
# MACアドレスの前後の部分を削除
GROUP_NETRORK_MAC_ADDRESS=${GROUP_NETRORK_MAC_ADDRESS%,*}
GROUP_NETRORK_MAC_ADDRESS=${GROUP_NETRORK_MAC_ADDRESS#*=}

# VYOS_NETWORK_BRIDGEとnetworkアドレスは同じ
Proxmox_side_IP_ADDRESS="192.168.${VYOS_NETWORK_BRIDGE}.${GROUP_NETWORK_BRIDGE}"
VyOS_side_NETWORK="192.168.${GROUP_NETWORK_BRIDGE}"
MOUNT_DIR="/mnt/vm$VM_NUM"

CONFIG_FILE="$MOUNT_DIR/boot/1.1.7/live-rw/config/config.boot"

sed -i -e "s/192.168.100.221/$Proxmox_side_IP_ADDRESS/g" $CONFIG_FILE
sed -i -e "s/192.168.110/$VyOS_side_NETWORK/g" $CONFIG_FILE
sed -i -e "s/192.168.100/${Proxmox_side_IP_ADDRESS%.*}/g" $CONFIG_FILE

sed -i -e "0,/hw-id/s/hw-id.*/hw-id ${VYOS_NETWORK_BRIDGE}/g" $CONFIG_FILE
#sed -i -e "0,/hw-id/!{0,/hw-id/s/hw-id.*/hw-id ${GROUP_NETRORK_MAC_ADDRESS}/}" $CONFIG_FILE
awk '/hw-id/{c++;if(c==2){sub("hw-id.*","hw-id $GROUP_NETRORK_MAC_ADDRESS");c==0}}1' $CONFIG_FILE >& /dev/null
