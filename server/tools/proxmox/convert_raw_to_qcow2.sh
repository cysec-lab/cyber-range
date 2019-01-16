#!/bin/bash

if [ $# -ne 1 ]; then
    echo "[File full path] need"
    echo "example:"
    echo "$0 /var/lib/vz/images/101/vm-101-disk-1.raw"
    exit 1
fi

RAW_FILE_PATH=$1
QCOW2_FILE_PATH=`echo $RAW_FILE_PATH | sed 's/raw/qcow2/g'`

if [ ! -e $RAW_FILE_PATH ]; then
    echo "raw file is not exists"
    exit 1
fi

# データがあれば終了
if [ -e $QCOW2_FILE_PATH ]; then
    echo "already $QCOW2_FILE_PATH exist"
    exit 1
fi

qemu-img convert -f raw -O qcow2 $RAW_FILE_PATH $QCOW2_FILE_PATH
rm $RAW_FILE_PATH
