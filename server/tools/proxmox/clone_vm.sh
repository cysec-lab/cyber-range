#!/bin/bash
#TODO VM IPアドレス
#TODO onboot yes
# フルクローンするスクリプト

if [ $# -lt 5 ]; then
    echo "[VM NUM] [TEMPLATE_NUM] [PC TYPE] [TARGET STRAGE] [BRIDGE_NUMS]... need"
    echo "example:"
    echo "$0 111 719 web 11"
    exit 1
fi

CLONE_NUM=$1
TEMPLATE_NUM=$2
PC_TYPE=$3
TARGET_STRAGE=$4
BRIDGE_NUMS=(${@:5}) # BRIDGE_NUMS部分を配列で変数に代入
VM_NAME=$PC_TYPE$CLONE_NUM
CLONE_CONFIG_PATH=/etc/pve/qemu-server/${CLONE_NUM}.conf
#IP_ADDRESS="192.168.1${CLONE_NUM:1:1}0.${CLONE_NUM:1:2}"
#TEMPLATE_NAME=$PC_TYPE$TEMPLATE_NUM

# clone
qm clone $TEMPLATE_NUM $CLONE_NUM --name $VM_NAME --full --storage $TARGET_STRAGE #--format raw --full

# change vm config file
for ((i=0;i<${#BRIDGE_NUMS[@]};i++)); do
    # bridgeを変更する行のbridge名を変更した新しいルールを作成する
    # 正規表現でbridgeの前のe1000の情報を保持できず二段階で処理をしている
    new_rule=`grep "net${i}:" $CLONE_CONFIG_PATH | head -n 1 | sed -e "s/bridge=.*/bridge=vmbr${BRIDGE_NUMS[i]}/g"`
    # clone時にconfファイルにparentとして以前のデータが残ることがあるが前のデータを残すために最初にマッチした行のみ変更を加える
    sed -i -e "0,/^net${i}/s/^net${i}.*bridge=.*/$new_rule/g" $CLONE_CONFIG_PATH
done

#./disk_mount.sh $CLONE_NUM $IP_ADDRESS $PC_TYPE $TEMPLATE_NAME

# start vm
#qm start $CLONE_NUM


# serial console connection setup
#qm set $CLONE_NUM -serial0 socket


# after clone setup
#./expect_serial_clone.sh $CLONE_NUM 192.168.130.${CLONE_NUM:1:2} $TEMPLATE_NAME$CLONE_NUM
