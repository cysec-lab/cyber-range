#!/bin/bash

if [ $# -ne 2 ]; then
    echo "[NBD num] [Mount file path] need"
    echo "example:"
    echo "$0 0 /var/lib/vz/images/111/vm-111-disk-1.qcow2"
    exit 1
fi

NBD_NUM=$1
MOUNT_FILE_PATH=$2
#MOUNT_FILE_PATH="/var/lib/vz/images/$VM_NUM/vm-${VM_NUM}-disk-1.qcow2"
MAX_PART=16

if [ ! -e $MOUNT_FILE_PATH ]; then
    echo "$MOUNT_FILE_PATH file is not exist"
    exit 1
fi

# parted install LVM is need parted
result=`dpkg -l | grep parted`
if [ ${#result} -eq 0 ]; then
    apt-get install -y parted
fi

modprobe nbd max_part=$MAX_PART

# 排他的制御 ->
# flockコマンド
# TODO ロックファイル置きっぱなし
#LOCK_FILE='/tmp/example.lock'
#mkdir $LOCK_FILE

# 参考:http://fj.hatenablog.jp/entry/2016/03/12/223319
#(
#    flock -w 60 || {
#        echo "ERROR: lock timeout" 1>&2
#        exit 1;
#    }
#
# disk image mount
# TODO 同時mountしてしまうとUUID重複で操作が出来なくなる
#      排他制御が必要

if [[ "$MOUNT_FILE_PATH" =~ 'rpool' ]]; then
    # ZFSクローンの場合
    qemu-nbd -c /dev/nbd$NBD_NUM -f raw $MOUNT_FILE_PATH # 拡張子を明示する
else
    # FULLクローンの場合
    qemu-nbd -c /dev/nbd$NBD_NUM $MOUNT_FILE_PATH
fi
sleep 2
partprobe /dev/nbd$NBD_NUM
