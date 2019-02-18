#!/bin/bash

if [ $# -ne 3 ]; then
    echo "[vm num] [VYOS_NETWORK_BRIDGE] [GROUP_NETWORK_BRIDGE] need"
    echo "example:"
    echo "$0 111 1 132"
    exit 1
fi

VM_NUM=$1
VYOS_NETWORK_BRIDGE=$2
GROUP_NETWORK_BRIDGE=$3

DISK_DATA_DIR="/dev/rpool/data"
DISK_DATA_FILE="$DISK_DATA_DIR/vm-${VM_NUM}-disk-1"
MOUNT_DIR="/mnt/vm$VM_NUM"

tool_dir=/root/github/cyber_range/server/tools/proxmox
MAX_PART=16

# ZFS Cloneが終わるのを待つ
if [ ! -e $DISK_DATA_FILE ]; then
    sleep 1
fi

HANDRED_NUM=${VM_NUM:0:1}
HANDRED_NUM=$((HANDRED_NUM-1))
#TENS_NUM=${VM_NUM:1:1}
#TENS_PLACE=$((TENS_PLACE-1))
ONE_PLACE=${VM_NUM:2:1}
ONE_PLACE=$((ONE_PLACE-1))
NBD_NUM=$(((HANDRED_NUM*6 + ONE_NUM) % MAX_PART))

# ディスクイメージのマウント
$tool_dir/disk_mount.sh $NBD_NUM $DISK_DATA_FILE

mkdir $MOUNT_DIR
mount /dev/nbd${NBD_NUM}p1 $MOUNT_DIR
   
# VM clone setup
$tool_dir/clone_vyos.sh $VM_NUM $VYOS_NETWORK_BRIDGE $GROUP_NETWORK_BRIDGE

# Phisical Volume umount
umount $MOUNT_DIR

# cleanup
rmdir $MOUNT_DIR
#vgchange -an vg_$TEMPLATE_NAME
#vgchange -an vg_$VM_NUM
qemu-nbd -d /dev/nbd$NBD_NUM
