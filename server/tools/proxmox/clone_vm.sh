#!/bin/bash
#TODO VM IPアドレス

if [ $# -ne 3 ]; then
    echo "[VM NUM] [TEMPLATE_NUM] [PC TYPE]  need"
    echo "example:"
    echo "$0 111 719 web"
    exit 1
fi

#TEMPLATE_NAME='web'
#TEMPLATE_NUM='414'
#CLONE_NUM='464'

CLONE_NUM=$1
TEMPLATE_NUM=$2
PC_TYPE=$3
VM_NAME=$PC_TYPE$CLONE_NUM
#IP_ADDRESS="192.168.1${CLONE_NUM:1:1}0.${CLONE_NUM:1:2}"
#TEMPLATE_NAME=$PC_TYPE$TEMPLATE_NUM

# clone
qm clone $TEMPLATE_NUM $CLONE_NUM --name $VM_NAME --full #--format raw --full

#./disk_mount.sh $CLONE_NUM $IP_ADDRESS $PC_TYPE $TEMPLATE_NAME

# start vm
#qm start $CLONE_NUM


# serial console connection setup
#qm set $CLONE_NUM -serial0 socket


# after clone setup
#./expect_serial_clone.sh $CLONE_NUM 192.168.130.${CLONE_NUM:1:2} $TEMPLATE_NAME$CLONE_NUM
