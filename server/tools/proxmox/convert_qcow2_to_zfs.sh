#!/bin/bash

if [ $# -ne 4 ]; then
    echo "[vm num] [Pool Name] [VM SIZE] [qcow2 file full path] need"
    echo "example:"
    echo "$0 100 rpool 32 /var/lib/vz/images/900/vm-900-disk-1.qcow2"
    exit 1
fi

VM_NUM=$1
POOL_NAME=$2
POOL_SIZE=$3
QCOW2_FILE_PATH=$4

# プール内の領域を作る
zfs create -V ${POOL_SIZE}G $POOL_NAME/data/vm-${VM_NUM}-disk-1

# parted install LVM is need parted
result=`dpkg -l | grep parted`
if [ ${#result} -eq 0 ]; then
    apt-get install -y parted
fi

modprobe nbd max_part=16

qemu-nbd -c /dev/nbd0 $QCOW2_FILE_PATH
time dd if=/dev/nbd0 of=/dev/zvol/$POOL_NAME/data/vm-${VM_NUM}-disk-1 bs=16M
qemu-nbd -d /dev/nbd0
