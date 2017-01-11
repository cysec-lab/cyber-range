#!/bin/bash
#TODO VM IPアドレス

if [ $# -ne 3 ]; then
    echo "[tempalte name] & [template num] & [new vm num] need"
    echo "example:"
    echo "./clone_vm.sh web 111 222"
    exit 1
fi

#TEMPLATE_NAME='web'
#TEMPLATE_NUM='414'
#CLONE_NUM='464'

TEMPLATE_NAME=$1
TEMPLATE_NUM=$2
CLONE_NUM=$3

# clone
qm clone $TEMPLATE_NUM $CLONE_NUM --name $TEMPLATE_NAME$CLONE_NUM --format raw --full

# serial console connection setup
qm set $CLONE_NUM -serial0 socket

# start vm
qm start $CLONE_NUM

# after clone setup
./expect_serial_clone.sh $CLONE_NUM 192.168.130.${CLONE_NUM:1:2} $TEMPLATE_NAME$CLONE_NUM
