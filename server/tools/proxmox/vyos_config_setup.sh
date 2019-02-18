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

QEOW2_FILE_PATH="/var/lib/vz/images/$VM_NUM/vm-${VM_NUM}-disk-1.qcow2"
RAW_FILE_PATH=`echo $QEOW2_FILE_PATH | sed 's/qcow2/raw/g'`
CONFIG_FILE_PATH="/etc/pve/qemu-server/${VM_NUM}.conf"
MOUNT_DIR="/mnt/vm$VM_NUM"

tool_dir=/root/github/cyber_range/server/tools/proxmox

# ファイルの有無とフォーマットチェック+rawの場合はqcow2に変更
$tool_dir/chg_format.sh $VM_NUM

#TENS_PLACE=${VM_NUM:1:1}
#TENS_PLACE=$((TENS_PLACE-1))
#ONE_PLACE=${VM_NUM:2:1}
#ONE_PLACE=$((ONE_PLACE-1))
#NBD_NUM=$((TENS_PLACE*4 + ONE_PLACE))
NBD_NUM=${VM_NUM:0:1}

# ディスクイメージのマウント
$tool_dir/disk_mount.sh $NBD_NUM $QEOW2_FILE_PATH

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

