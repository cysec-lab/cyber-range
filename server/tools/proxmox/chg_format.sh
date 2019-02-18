#!/bin/bash

if [ $# -ne 1 ]; then
    echo "[vm num] need"
    echo "example:"
    echo "$0 111"
    exit 1
fi

VM_NUM=$1

QEOW2_FILE_PATH="/var/lib/vz/images/$VM_NUM/vm-${VM_NUM}-disk-1.qcow2"
RAW_FILE_PATH=`echo $QEOW2_FILE_PATH | sed 's/qcow2/raw/g'`
CONFIG_FILE_PATH="/etc/pve/qemu-server/${VM_NUM}.conf"

tool_dir=/root/github/cyber_range/server/tools/proxmox
util_dir=/root/github/cyber_range/server/tools/utilities/convert_image_format

if [ ! -e $QEOW2_FILE_PATH ]; then
    if [ ! -e $RAW_FILE_PATH ]; then
        echo "Image file dose not exist"
        exit 1
    fi
    $util_dir/convert_raw_to_qcow2.sh $RAW_FILE_PATH
    sed -ie "s/raw/qcow2/g" $CONFIG_FILE_PATH
fi

