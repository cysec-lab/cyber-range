#!/bin/sh

if [ $# -ne 1 ]; then
    echo "delete vm num need"
    echo "example:"
    echo "$0 111"
    exit 1
fi

file="/etc/pve/qemu-server/${1}.conf"
if [ -e $file ]; then
    qm stop $1
    qm destroy $1
    echo "$1 VM delete success"
fi
