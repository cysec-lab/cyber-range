#!/bin/bash

if [ $# -lt 4 ]; then
    echo "[NEW VM NUM] [TEMPLATE NUM] [PC TYPE] [BRIDGE_NUMS]... need"
    echo "example:"
    echo "$0 111 719 vyos 1 123"
    exit 1
fi

CLONE_NUM=$1
TEMPLATE_NUM=$2
PC_TYPE=$3
BRIDGE_NUMS=(${@:4}) # BRIDGE_NUMS部分を配列で変数に代入
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
    # bridgeを変更する行のbridge名を変更した新しいルールを作成する
    # 正規表現でbridgeの前のe1000の情報を保持できず二段階で処理をしている
    new_rule=`grep "net${i}:" $CLONE_CONFIG_PATH | head -n 1 | sed -e "s/bridge=.*/bridge=vmbr${BRIDGE_NUMS[i]}/g"`
    # clone時にconfファイルにparentとして以前のデータが残ることがあるが前のデータを残すために最初にマッチした行のみ変更を加える
    sed -i -e "0,/^net${i}/s/^net${i}.*bridge=.*/$new_rule/g" $CLONE_CONFIG_PATH
done
