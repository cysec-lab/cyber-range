#!/bin/bash

if [ $# -lt 4 ]; then
    echo "[NEW VM NUM] [TEMPLATE NUM] [VM_NAME] [BRIDGE_NUMS]... need"
    echo "example:"
    echo "$0 111 719 vyos111 1 123"
    exit 1
fi

CLONE_NUM=$1
TEMPLATE_NUM=$2
VM_NAME=$3
BRIDGE_NUMS=(${@:4}) # BRIDGE_NUMS部分を配列で変数に代入
TEMPLATE_CONFIG_PATH=/etc/pve/qemu-server/${TEMPLATE_NUM}.conf
CLONE_CONFIG_PATH=/etc/pve/qemu-server/${CLONE_NUM}.conf
SNAPSHOT=rpool/data/vm-${TEMPLATE_NUM}-disk-1@${TEMPLATE_NUM}_snapshot


# check snapshot
snapshot_check_cmd="zfs list -r -t snapshot -o name,creation rpool"
eval "$snapshot_check_cmd | grep $SNAPSHOT > /dev/null"
# snapshot not exist
if [ $? -ne 0 ]; then
    # create snapshot
    zfs snapshot -r $SNAPSHOT
fi

# zfs clone
zfs clone $SNAPSHOT rpool/data/vm-${CLONE_NUM}-disk-1

# copy vm config file
cp $TEMPLATE_CONFIG_PATH $CLONE_CONFIG_PATH
sed -i -e "s/vm-${TEMPLATE_NUM}-disk-1/vm-${CLONE_NUM}-disk-1/g" $CLONE_CONFIG_PATH
sed -i -e "s/local-tvm/local-zfs/g" $CLONE_CONFIG_PATH
sed -i -e "s/^name:.*/name: ${VM_NAME}/g" $CLONE_CONFIG_PATH
for ((i=0;i<${#BRIDGE_NUMS[@]};i++)); do
    # change bridge name
    # ZFSクローンではmac addressが変更されないので、新たなmac addressを作成し置き換える
    mac_address=02:`dd if=/dev/urandom bs=1024 count=1 2>/dev/null|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/\1:\2:\3:\4:\5/'`
    new_rule="net${i}: e1000=${mac_address},bridge=vmbr${BRIDGE_NUMS[i]}"
    # clone時にconfファイルにparentとして以前のデータが残ることがあるが前のデータを残すために最初にマッチした行のみ変更を加える
    sed -i -e "0,/^net${i}/s/^net${i}.*/$new_rule/g" $CLONE_CONFIG_PATH
done
