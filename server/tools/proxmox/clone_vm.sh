#!/bin/bash
# ZFS FULLクローン両方に対応したスクリプト
#TODO onboot yes : yes設定にしないとProxmoxを再起動した際に自動起動してくれないVyOSはProxmox起動時に起動してほしい

if [ $# -lt 6 ]; then
    echo "[CLONE TYPE] [VM NUM] [TEMPLATE_NUM] [VM NAME] [TARGET STRAGE] [BRIDGE_NUMS]... need"
    echo "example:"
    echo "$0 zfs 111 719 web111 111"
    exit 1
fi

CLONE_TYPE=$1
CLONE_NUM=$2
TEMPLATE_NUM=$3
VM_NAME=$4
TARGET_STRAGE=$5
BRIDGE_NUMS=(${@:6}) # BRIDGE_NUMS部分を配列で変数に代入

TEMPLATE_CONFIG_PATH=/etc/pve/qemu-server/${TEMPLATE_NUM}.conf
CLONE_CONFIG_PATH=/etc/pve/qemu-server/${CLONE_NUM}.conf
SNAPSHOT=rpool/data/vm-${TEMPLATE_NUM}-disk-1@${TEMPLATE_NUM}_snapshot

tool_dir=/root/github/cyber-range/server/tools/proxmox

# VMのクローン
if [ "$CLONE_TYPE" = 'zfs' ]; then
    # ZFS
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
elif [ "$CLONE_TYPE" = 'full' ]; then
    # QEMU
    qm clone $TEMPLATE_NUM $CLONE_NUM --name $VM_NAME --full --storage $TARGET_STRAGE #--format raw --full
    
    # localストレージの場合はqcow2に変更する
    # local-zfsストレージはrawファイルのまま．rollbackはzfsで行うため問題ない
    if [ "$TARGET_STRAGE" = 'local' ]; then
        # ファイルの有無とフォーマットチェック+rawの場合はqcow2に変更
        $tool_dir/chg_format.sh $CLONE_NUM
    fi
else
    echo 'clone type is zfs or full'
    exit 1
fi


# クローンしたVMの設定を変更
for ((i=0;i<${#BRIDGE_NUMS[@]};i++)); do
    if [ "$CLONE_TYPE" = 'zfs' ]; then
        # ZFSクローンではmac addressが変更されないので、新たなmac addressを作成し置き換える
        mac_address=`dd if=/dev/urandom bs=1024 count=1 2>/dev/null|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/' | tr '[a-z]' '[A-Z]'`
        new_rule="net${i}: e1000=${mac_address},bridge=vmbr${BRIDGE_NUMS[i]}"
        # clone時にconfファイルにparentとして以前のデータが残ることがあるが前のデータを残すために最初にマッチした行のみ変更を加える
        sed -i -e "0,/^net${i}/s/^net${i}.*/$new_rule/g" $CLONE_CONFIG_PATH
    else
        # bridgeを変更する行のbridge名を変更した新しいルールを作成する
        # 正規表現でbridgeの前のe1000の情報を保持できず二段階で処理をしている
        new_rule=`grep "net${i}:" $CLONE_CONFIG_PATH | head -n 1 | sed -e "s/bridge=.*/bridge=vmbr${BRIDGE_NUMS[i]}/g"`
        # clone時にconfファイルにparentとして以前のデータが残ることがあるが前のデータを残すために最初にマッチした行のみ変更を加える
        sed -i -e "0,/^net${i}/s/^net${i}.*bridge=.*/$new_rule/g" $CLONE_CONFIG_PATH
    fi
done
