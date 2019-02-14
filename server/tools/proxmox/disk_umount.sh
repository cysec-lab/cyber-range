#!/bin/bash

if [ $# -ne 2 ]; then
    echo "[NBD num] [NEW VG name] need"
    echo "example:"
    echo "$0 111 vg_111"
    exit 1
fi

NBD_NUM=$1
NEW_VG_NAME=$2

# cleanup
vgchange -an $NEW_VG_NAME
qemu-nbd -d /dev/nbd$NBD_NUM
