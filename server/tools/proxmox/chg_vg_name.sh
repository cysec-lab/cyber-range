#!/bin/bash

if [ $# -ne 2 ]; then
    echo "[vm num] [new VG name]need"
    echo "example:"
    echo "$0 111 vg_111"
    exit 1
fi

VM_NUM=$1
NEW_VG_NAME=$2

QEOW2_FILE_PATH="/var/lib/vz/images/$VM_NUM/vm-${VM_NUM}-disk-1.qcow2"
MAX_PART=16
NBD_NUM=0

if [ ! -e $QEOW2_FILE_PATH ]; then
    echo "$QEOW2_FILE_PATH file is not exists"
    exit 1
fi

TENS_PLACE=${VM_NUM:1:1}
TENS_PLACE=$((TENS_PLACE-1))
TENS_PLACE=${VM_NUM:2:1}
ONE_PLACE=$((ONE_PLACE-2))
#NBD_NUM=$(((TENS_PLACE*4 + ONE_PLACE) % MAX_PART))

TEMP_VG_NAME=`vgdisplay | grep 'VG Name' | grep -v 'pve' | awk '{ print $3 }'`

modprobe nbd max_part=$MAX_PART

qemu-nbd -c /dev/nbd$NBD_NUM $QEOW2_FILE_PATH
partprobe /dev/nbd$NBD_NUM
   
# cloneによるPV,VGのUUID副重問題の解決
pvchange --uuid /dev/nbd${NBD_NUM}p2
vgrename $NEW_VG_NAME $TEMP_VG_NAME
vgchange --uuid $TEMP_VG_NAME
qemu-nbd -d /dev/nbd$NBD_NUM
