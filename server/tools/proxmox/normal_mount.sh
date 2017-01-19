#!/bin/bash
# TODO cloneテンプレートのVG名の究明（ホスト名?）
#      TEMPLATE_NAMEの変更
# TODO UUID変更は本当に必要ないのかの究明

if [ $# -ne 3 ]; then echo "[vm num] [TEMPLATE_NAME] [NBD num] need"
    echo "example:"
    echo "$0 [111] [VolGroup] [0]"
    exit 1
fi

VM_NUM=$1
TEMPLATE_NAME=$2
NBD_NUM=$3
VG_NAME=vg_$VM_NUM
MOUNT_DIR="/mnt/vm${VM_NUM}"

QEOW2_FILE_PATH="/var/lib/vz/images/$VM_NUM/vm-${VM_NUM}-disk-1.qcow2"

if [ ! -e $QEOW2_FILE_PATH ]; then
    echo "file is not exists"
    exit 1
fi

# parted install LVM is need parted
apt-get install parted

modprobe nbd max_part=16

qemu-nbd -c /dev/nbd$NBD_NUM $QEOW2_FILE_PATH
partprobe /dev/nbd$NBD_NUM

#pvdisplay

#vgdisplay

# cloneによるPV,VGのUUID副重問題の解決
pvchange --uuid /dev/nbd${NBD_NUM}p2
vgrename $TEMPLATE_NAME $VG_NAME      # kernel panicの原因
vgchange --uuid $VG_NAME
vgchange -ay $VG_NAME

#pvdisplay

#vgdisplay

