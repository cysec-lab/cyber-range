#!/bin/bash
#TODO VM IPアドレス

if [ $# -ne 3 ]; then
    echo "[VM NUM] [TEMPLATE_NAME] [PC TYPE] need"
    echo "example:"
    echo "$0 111 719 web"
    exit 1
fi

CLONE_NUM=$1
TEMPLATE_NUM=$2
PC_TYPE=$3
VM_NAME=$PC_TYPE$CLONE_NUM
TEMPLATE_CONFIG_PATH=/etc/pve/qemu-server/${TEMPLATE_NUM}.conf
CLONE_CONFIG_PATH=/etc/pve/qemu-server/${CLONE_NUM}.conf
SNAPSHOT=rpool/data/vm-${TEMPLATE_NUM}-disk-1@${TEMPLATE_NUM}_snapshot

# check snapshot
snapshot_check_cmd="zfs list -r -t snapshot -o name,creation rpool"
eval "$snapshot_check_cmd | grep $SNAPSHOT > /dev/null"
# snapshot not exist
if [ $? -ne 0 ]; then
    # create snapshot
    zfs snapshot $SNAPSHOT
fi

# zfs clone
zfs clone $SNAPSHOT rpool/data/vm-${CLONE_NUM}-disk-1

# copy vm config file
cp $TEMPLATE_CONFIG_PATH $CLONE_CONFIG_PATH
sed -i -e "s/vm-${TEMPLATE_NUM}-disk-1/vm-${CLONE_NUM}-disk-1/g" $CLONE_CONFIG_PATH
sed -i -e "s/^name:.*/name: ${VM_NAME}/g" $CLONE_CONFIG_PATH
