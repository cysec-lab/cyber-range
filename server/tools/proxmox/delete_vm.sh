#!/bin/sh

if [ $# -ne 1 ]; then
    echo "delete vm num need"
    echo "example:"
    echo "./delete_vm.sh 111"
    exit 1
fi

qm stop $1
qm destroy $1
