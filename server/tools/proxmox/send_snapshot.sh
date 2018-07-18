#!/bin/bash

if [ $# -ne 4 ]; then
    echo "[vm num] [Pool Name] [VM SIZE] [qcow2 file full path] need"
    echo "example:"
    echo "$0 100 rpool 32 /var/lib/vz/images/900/vm-900-disk-1.qcow2"
    exit 1
fi

VM_NUM=$1
SRC_POOL_NAME=$2
DIST_POOL_NAME=$3
SRC_ZFS_FILE_PATH=$SRC_POOL_NAME/data/vm-${VM_NUM}-disk-1
DIST_ZFS_FILE_PATH=$DIST_POOL_NAME/data/vm-${VM_NUM}-disk-1

# スナップショットがあるか判定
zfs snapshot -r tvmpool/data/vm-902-disk-1@902_snapshot

# プールが存在しているのかの判定＋削除
time zfs send tvmpool/data/vm-902-disk-1@902_snapshot | zfs receive -F rpool/data/vm-902-disk-1


#POOL_SIZE=$3
#QCOW2_FILE_PATH=$4
#
## 前のデータを削除
#result=`zfs list | grep $ZFS_FILE_PATH`
#if [ ${#result} -ne 0 ]; then
#    zfs destroy -R $ZFS_FILE_PATH
#fi
## プール内に領域を作る
#zfs create -V ${POOL_SIZE}G $ZFS_FILE_PATH
#
## parted install LVM is need parted
#result=`dpkg -l | grep parted`
#if [ ${#result} -eq 0 ]; then
#    apt-get install -y parted
#fi
#
#modprobe nbd max_part=16
#
#qemu-nbd -c /dev/nbd0 $QCOW2_FILE_PATH
#sleep 2
#time dd if=/dev/nbd0 of=/dev/zvol/$ZFS_FILE_PATH
#qemu-nbd -d /dev/nbd0
