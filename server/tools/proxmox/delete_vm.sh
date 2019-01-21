#!/bin/sh

if [ $# -ne 1 ]; then
    echo "delete vm num need"
    echo "example:"
    echo "$0 111"
    exit 1
fi

vm=$1

file="/etc/pve/qemu-server/${vm}.conf"
if [ -e $file ]; then
    qm stop $vm
    qm destroy $vm
    while [ `echo $?` != 0 ]; do
        qm unlock  $vm
        qm destroy $vm
    done
    echo "$vm VM delete success"
fi
