#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Need new [VM num]"
  echo "$0 [228]"
  exit 1
fi

VM_NUM=$1
Proxmox_side_IP_ADDRESS="192.168.100.$VM_NUM"
VyOS_side_NETWORK="192.168.1${VM_NUM:2:1}0"
MOUNT_DIR="/mnt/vm$VM_NUM"

CONFIG_FILE="$MOUNT_DIR/boot/1.1.7/live-rw/config/config.boot"

sed -i -e "s/192.168.100.221/$Proxmox_side_IP_ADDRESS/g" $CONFIG_FILE
sed -i -e "s/192.168.110/$VyOS_side_NETWORK/g" $CONFIG_FILE
