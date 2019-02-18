#!/bin/bash
# TODO ファイル分割

if [ $# -ne 3 ]; then
    echo "[vm num] [IP Address] [hostname] need"
    echo "example:"
    echo "$0 111 192.168.110.11 centos6-i386"
    exit 1
fi

VM_NUM=$1
IP_ADDRESS=$2
HOSTNAME=$3

DISK_DATA_DIR="/dev/rpool/data"
DISK_DATA_FILE="$DISK_DATA_DIR/vm-${VM_NUM}-disk-1"
MOUNT_DIR="/mnt/vm$VM_NUM"

tool_dir=/root/github/cyber_range/server/tools/proxmox
MAX_PART=16

# ZFS Cloneが終わるのを待つ
while [ ! -e $DISK_DATA_FILE ]; do
    sleep 1
done

HANDRED_NUM=${VM_NUM:0:1}
HANDRED_NUM=$((HANDRED_NUM-1))
#TEN_NUM=${VM_NUM:1:1}
ONE_NUM=${VM_NUM:2:1}
ONE_NUM=$((ONE_NUM-1))
NBD_NUM=$(((HANDRED_NUM*6 + ONE_NUM) % MAX_PART))

# ディスクイメージのマウント
$tool_dir/disk_mount.sh $NBD_NUM $DISK_DATA_FILE

# 変更すべきテンプレートVMのVG nameを取得
OLD_VG_NAME=`vgdisplay | grep 'VG Name' | grep -v 'pve' | awk '{ print $3 }'`
NEW_VG_NAME="vg_$VM_NUM"

# VG nameの変更とUUID重複問題の解決
$tool_dir/uuid_reset.sh $NBD_NUM $OLD_VG_NAME $NEW_VG_NAME

# マウント用のディレクトリ作成
mkdir $MOUNT_DIR

vgchange -ay $NEW_VG_NAME

# grubに記述されているVG nameを修正
mount /dev/nbd${NBD_NUM}p1 $MOUNT_DIR
#mount $DISK_DATA_DIR/vm-${VM_NUM}-disk-1-part1 $MOUNT_DIR 左でもできた
sed -i -e "s/$OLD_VG_NAME/$NEW_VG_NAME/g" $MOUNT_DIR/grub/grub.conf
sync
sync
sync
umount $MOUNT_DIR

# 設定ファイルが記述されている領域をマウント
mount /dev/$NEW_VG_NAME/lv_root $MOUNT_DIR

# fstabに記述されているVG nameを修正
sed -i -e "s/$OLD_VG_NAME/$NEW_VG_NAME/g" $MOUNT_DIR/etc/fstab

# クローンされたVMをサイバーレンジに使えるように設定変更する(IPアドレスなど)
$tool_dir/clone.sh $VM_NUM $IP_ADDRESS $HOSTNAME
#$tool_dir/nfs_setup.sh $VM_NUM $IP_ADDRESS $PC_TYPE # nfsを利用する場合に実行(現在利用していない)
sync
sync
sync
umount $MOUNT_DIR

# ディスクイメージのアンマウント
$tool_dir/disk_umount.sh $NBD_NUM $NEW_VG_NAME

# マウント用のディレクトリ削除
rmdir $MOUNT_DIR
