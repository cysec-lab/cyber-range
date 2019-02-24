#!/bin/bash
# VMの設定ファイルとイメージをコピーするスクリプト

if [ $# -ne 4 ]; then
    echo "[Clone type] [テンプレートVM番号] [作成するVMの開始数字] [作成するVMの終了番号]"
    echo "$0 full 900 950 980"
    echo "900のテンプレートVMを950~980にクローンする"
    exit 1
fi

CLONE_TYPE=$1
TEMPLATE_VM_NUM=$2
START_NUM=$3
END_NUM=$4

# Get JSON data
json_conf_data=`cat json_files/config_info.json`
git_home_get_command=`echo $json_conf_data | jq '.git_home_get_command' | sed 's/"//g'`
git_home=`$git_home_get_command`
TOOL_DIR=$git_home`echo $json_conf_data | jq '.tool_dir' | sed 's/"//g'`
CONF_DIR=$git_home`echo $json_conf_data | jq '.vm_config_dir' | sed 's/"//g'`


# CLONE_TYPEのチェック
# TARGET_STRAGEを指定しているが利用していない
# TARGET_STRAGEはlocal-zfsに決め打ちしている
if [ "$CLONE_TYPE" = 'zfs' ]; then
    TARGET_STRAGE='local-zfs' # zfs clone target strage
elif [ "$CLONE_TYPE" = 'full' ]; then
    TARGET_STRAGE='local'     # full clone target strage
else
    echo 'invalid data'
    echo 'clone type is zfs or full'
    exit 1
fi

# テンプレートVMの有無をチェック
if [ ! -e "$CONF_DIR/${TEMPLATE_VM_NUM}.conf" ]; then
    echo "${TEMPLATE_VM_NUM}番のテンプレートVMは存在しません"
    exit 1
fi

# 作成VMのレンジチェック
for ((new_vm_num=$START_NUM; new_vm_num <= $END_NUM; new_vm_num++)); do
    if [ -e "$CONF_DIR/${new_vm_num}.conf" ]; then
        echo "${new_vm_num}番はVMが存在しています"
        exit 1
    fi
done

# クローン後のVM名は「テンプレートVMの名前 + 数字」とするので、テンプレートVMの名前を取得する
TEMPLATE_VM_NAME=`grep -e "^name:" $CONF_DIR/${TEMPLATE_VM_NUM}.conf | awk '{print $2}'`
# VMのブリッジ番号はテンプレートVMと同じものを利用する
TEMPLATE_VM_BRIDGE_NUMS=(`grep -e "^net" /etc/pve/qemu-server/${TEMPLATE_VM_NUM}.conf | awk -F 'vmbr' '{print $2}')

# VMのクローン
for ((new_num=$START_NUM, i=1; new_vm_num <= $END_NUM; new_vm_num++, i++)); do
    NEW_VM_NAME=$TEMPLATE_VM_NAME$i
    bash $TOOL_DIR/clone_vm.sh $CLONE_TYPE $new_vm_num $TEMPLATE_VM_NUM  $TEMPLATE_VM_NAME local-zfs ${TEMPLATE_VM_BRIDGE_NUMS[@]}
done
