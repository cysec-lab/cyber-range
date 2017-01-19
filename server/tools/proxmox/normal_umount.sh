#!/bin/bash
# TODO cloneテンプレートのVG名の究明（ホスト名?）
#      TEMPLATE_NAMEの変更
# TODO UUID変更は本当に必要ないのかの究明

if [ $# -ne 2 ]; then
    echo "[VM num] [NBD num]need"
    echo "example:"
    echo "$0 111 0"
    exit 1
fi

VM_NUM=$1
NBD_NUM=$2

VG_NAME="vg_$VM_NUM"
MOUNT_DIR="/mnt/vm$VM_NUM"

# Phisical Volume umount
umount $MOUNT_DIR

# cleanup
rmdir $MOUNT_DIR

vgchange -an $VG_NAME
qemu-nbd -d /dev/nbd$NBD_NUM

