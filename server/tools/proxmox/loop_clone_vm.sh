#!/bin/bash
#TODO VM IPアドレス

if [ $# -ne 4 ]; then
    echo "[PC TYPE] [TEMPLATE_NUM] [VM NUM] [Loop Count] need"
    echo "example:"
    echo "$0 web 719 111 5"
    exit 1
fi

#TEMPLATE_NAME='web'
#TEMPLATE_NUM='414'
#CLONE_NUM='464'

PC_TYPE=$1
TEMPLATE_NUM=$2
CLONE_NUM=$3
LOOP_COUNT=$4
VM_NAME=$PC_TYPE$CLONE_NUM
#IP_ADDRESS="192.168.1${CLONE_NUM:1:1}0.${CLONE_NUM:1:2}"
#TEMPLATE_NAME=$PC_TYPE$TEMPLATE_NUM

# clone
for i in `seq 1 $LOOP_COUNT`
do
    clone_num=`expr $CLONE_NUM + $i - 1`
    ./clone_vm.sh $PC_TYPE  $TEMPLATE_NUM $clone_num
done
#qm clone $TEMPLATE_NUM $CLONE_NUM --name $VM_NAME --full #--format raw --full

#./disk_mount.sh $CLONE_NUM $IP_ADDRESS $PC_TYPE $TEMPLATE_NAME

# start vm
#qm start $CLONE_NUM


# serial console connection setup
#qm set $CLONE_NUM -serial0 socket


# after clone setup
#./expect_serial_clone.sh $CLONE_NUM 192.168.130.${CLONE_NUM:1:2} $TEMPLATE_NAME$CLONE_NUM
