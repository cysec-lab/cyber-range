#!/bin/bash

if [ $# -ne 1 ]; then
    echo "[vm num] need"
    echo "example:"
    echo "$0 111"
    exit 1
fi

VM_NUM=$1

QEOW2_FILE_PATH="/var/lib/vz/images/$VM_NUM/vm-${VM_NUM}-disk-1.qcow2"
MAX_PART=16

if [ ! -e $QEOW2_FILE_PATH ]; then
    echo "$QEOW2_FILE_PATH file is not exists"
    exit 1
fi

TENS_PLACE=${VM_NUM:1:1}
TENS_PLACE=$((TENS_PLACE-1))
TENS_PLACE=${VM_NUM:2:1}
ONE_PLACE=$((ONE_PLACE-2))
#NBD_NUM=$(((TENS_PLACE*4 + ONE_PLACE) % MAX_PART))

NBD_NUM=0
TEMPLATE_NAME='VolGroup'
NEW_NAME="vg_${VM_NUM}"

modprobe nbd max_part=$MAX_PART

qemu-nbd -c /dev/nbd$NBD_NUM $QEOW2_FILE_PATH
partprobe /dev/nbd$NBD_NUM
   
# cloneによるPV,VGのUUID副重問題の解決
pvchange --uuid /dev/nbd${NBD_NUM}p2
vgrename $NEW_NAME $TEMPLATE_NAME
vgchange --uuid $TEMPLATE_NAME
qemu-nbd -d /dev/nbd$NBD_NUM
