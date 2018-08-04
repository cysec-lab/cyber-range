#!/bin/bash

if [ $# -ne 3 ]; then
    echo "[vm num] [Src Pool Name] [Dist Pool Name] need"
    echo "example:"
    echo "$0 100 tvmpool rpool"
    exit 1
fi

VM_NUM=$1
SRC_POOL_NAME=$2
DIST_POOL_NAME=$3
SRC_ZFS_SNAPSHOT=$SRC_POOL_NAME/data/vm-${VM_NUM}-disk-1@${VM_NUM}_snapshot
DIST_ZFS_FILE_PATH=$DIST_POOL_NAME/data/vm-${VM_NUM}-disk-1
DIST_ZFS_SNAPSHOT=${DIST_ZFS_FILE_PATH}@${VM_NUM}_snapshot

# スナップショットがあるか判定＋ない場合は作成
result=`zfs list -t snapshot | grep ${SRC_ZFS_SNAPSHOT}`
if [ ${#result} -eq 0 ]; then
	zfs snapshot -r $SRC_ZFS_SNAPSHOT
fi

# スナップショットがあるか判定＋ある場合は削除
result=`zfs list -t snapshot | grep ${DIST_ZFS_SNAPSHOT}`
if [ ${#result} -eq 0 ]; then
	zfs destroy $DIST_ZFS_SNAPSHOT
fi

# スナップショットの送信
time zfs send $SRC_ZFS_SNAPSHOT | zfs receive -F $DIST_ZFS_FILE_PATH
