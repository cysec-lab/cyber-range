#!/bin/bash

if [ $# -ne 3 ]; then
    echo "[vm num] [Pool Name] [Dist images dir] need"
    echo "example:"
    echo "$0 100 rpool /var/lib/vz/images"
    exit 1
fi

VM_NUM=$1
POOL_NAME=$2
FILE_NAME=vm-${VM_NUM}-disk-1
DIST_FILE_PATH=${3}/${VM_NUM}/$FILE_NAME
ZFS_FILE_PATH=/dev/zvol/$POOL_NAME/data/$FILE_NAME

# データがあれば終了
if [ -e $DIST_FILE_PATH ]; then
    echo "already $DIST_FILE_PATH exist"
    exit 1
fi

# ディレクトリがなければ作成する
if [ ! -e ${DIST_FILE_PATH%/*} ]; then
    mkdir -p ${DIST_FILE_PATH%/*}
fi

time dd if=$ZFS_FILE_PATH of=${DIST_FILE_PATH}.raw bs=16MB
time qemu-img convert -f raw -O qcow2 ${DIST_FILE_PATH}.raw ${DIST_FILE_PATH}.qcow2
rm ${DIST_FILE_PATH}.raw
