#!/bin/bash

if [ $# -ne 3 ]; then
    echo "[NBD num] [OLD VG name] [NEW VG name] need"
    echo "example:"
    echo "$0 111 VolGroup vg_111"
    echo "args = $*"
    exit 1
fi

NBD_NUM=$1
OLD_VG_NAME=$2
NEW_VG_NAME=$3

# cloneによるPV,VGのUUID重複問題の解決
pvchange --uuid /dev/nbd${NBD_NUM}p2
vgrename $OLD_VG_NAME $NEW_VG_NAME   # kernel panicの原因
vgchange --uuid $NEW_VG_NAME
