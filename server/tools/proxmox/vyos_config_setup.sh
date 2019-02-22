#!/bin/bash

if [ $# -ne 4 ]; then
    echo "[clone type] [vm num] [VYOS_NETWORK_BRIDGE] [GROUP_NETWORK_BRIDGE] need"
    echo "example:"
    echo "$0 zfs 111 1 132"
    exit 1
fi

CLONE_TYPE=$1
VM_NUM=$2
VYOS_NETWORK_BRIDGE=$3
GROUP_NETWORK_BRIDGE=$4

DISK_DATA_DIR="/dev/rpool/data"
DISK_DATA_FILE="$DISK_DATA_DIR/vm-${VM_NUM}-disk-1"
QEOW2_FILE_PATH="/var/lib/vz/images/$VM_NUM/vm-${VM_NUM}-disk-1.qcow2"
RAW_FILE_PATH=`echo $QEOW2_FILE_PATH | sed 's/qcow2/raw/g'`
CONFIG_FILE_PATH="/etc/pve/qemu-server/${VM_NUM}.conf"
MOUNT_DIR="/mnt/vm$VM_NUM"

tool_dir=/root/github/cyber-range/server/tools/proxmox
MAX_PART=16

if [ "$CLONE_TYPE" = 'zfs' ]; then
    # ZFS Cloneが終わるのを待つ
    if [ ! -e $DISK_DATA_FILE ]; then
        sleep 1
    fi
elif [ "$CLONE_TYPE" = 'full' ]; then
    # ファイルの有無とフォーマットチェック+rawの場合はqcow2に変更
    $tool_dir/chg_format.sh $VM_NUM
else
    echo 'clone type is zfs or full'
    exit 1
fi

TENS_NUM=${VM_NUM:1:1}
#TENS_PLACE=$((TENS_PLACE-1))
ONE_PLACE=${VM_NUM:2:1}
ONE_PLACE=$((ONE_PLACE-1))
NBD_NUM=$(((TENS_NUM_NUM*4 + ONE_NUM) % MAX_PART))

# ディスクイメージのマウント
if [ "$CLONE_TYPE" = 'zfs' ]; then
    $tool_dir/disk_mount.sh $NBD_NUM $DISK_DATA_FILE
else
    $tool_dir/disk_mount.sh $NBD_NUM $QEOW2_FILE_PATH
fi

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
