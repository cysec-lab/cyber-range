#!/bin/sh

if [ $# -ne 1 ]; then
    echo "delete vm num need"
    echo "example:"
    echo "$0 111"
    exit 1
fi

qm stop $1
qm destroy $1
