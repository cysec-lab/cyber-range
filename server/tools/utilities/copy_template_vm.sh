#!/bin/bash
# VMの設定ファイルとイメージをコピーするスクリプト

if [ $# -ne 4 ]; then
    echo "[ストレージ名(local | local-zfs)] [VM num] [コピー元ルートPATH] [コピー先ルートPATH]"
    echo "$0 local-zfs 123 /mnt/hdd/pve/ /"
    exit 1
fi

STRAGE_NAME=$1
VM_NUM=$2
SOURCE_DIR=$3
DIST_DIR=$4

QCOW2_DIR=var/lib/vz/images/
CONF_PATH=etc/pve/qemu-server/

convert_tool_dir=/root/github/cyber-range/server/tools/utilities/convert_image_format

SOURCE_CONF_FILE="$SOURCE_DIR/$CONF_PATH/${VM_NUM}.conf"
DIST_CONF_FILE="$DIST_DIR/$CONF_PATH/${VM_NUM}.conf"

# ストレージ名チェック
if !([ "$STRAGE_NAME" = 'local' ] || [ "$STRAGE_NAME" = 'local-zfs' ] || [ "$STRAGE_NAME" = 'local-tvm' ]); then
    echo 'ストレージ名はlocal || local-zfs || local-tvmである必要があります'
    exit 1
fi

# 設定ファイルチェック
if [ -e "$DIST_CONF_FILE" ]; then
    echo "すでに $DIST_CONF_FILE の設定ファイルが存在しています"
    exit 1
fi
if [ ! -e "$SOURCE_CONF_FILE" ]; then
    echo "コピー元 $SOURCE_CONF_FILE の設定ファイルが存在しません"
    exit 1
fi

# 設定ファイルとイメージのコピー
cp $SOURCE_CONF_FILE $DIST_CONF_FILE
if [ "$STRAGE_NAME" = 'local' ]; then
    # 設定ファイルの修正
    result=`cat $DIST_CONF_FILE | grep -e "^ide0" | grep -e "local:$VM_NUM"`
    if [ ${#result} -eq 0 ]; then
        # local-zfs -> localに設定変更
        sed -i -e "s/-zfs:/:${VM_NUM}\//g" $DIST_CONF_FILE
        sed -i -e "s/disk-1/disk-1.qcow2/g" $DIST_CONF_FILE
        sed -i -e "/^scsihw:/d" $DIST_CONF_FILE
    fi
    # イメージのコピー
    cp -rf $SOURCE_DIR/$QCOW2_DIR/$VM_NUM $DIST_DIR/$QCOW2_DIR/
else
    # 設定ファイルの修正
    result=`cat $DIST_CONF_FILE | grep -e "^ide0" | grep -e "local-zfs"`
    if [ ${#result} -eq 0 ]; then
        # local -> local-zfsに設定変更
        sed -i -e "s/:$VM_NUM\//-zfs:/g" $DIST_CONF_FILE
        sed -i -e "s/disk-1.qcow2/disk-1/g" $DIST_CONF_FILE
        sed -i -e "/^ostype:/a scsihw: virtio-scsi-pci" $DIST_CONF_FILE
    fi
    # イメージのコピー
    $convert_tool_dir/convert_qcow2_to_zfs.sh $VM_NUM rpool 32 $SOURCE_DIR/$QCOW2_DIR/$VM_NUM
fi
