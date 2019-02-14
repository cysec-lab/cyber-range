#!/bin/bash
# TODO: change_format.sh
#       rawイメージのときはQCOW2に変更させたい

if [ $# -ne 3 ]; then
    echo "[VM num] [IP Address] [HOSTNAME] need"
    echo "example:"
    echo "$0 111 192.168.110.11 centos6-i386"
    exit 1
fi

VM_NUM=$1
IP_ADDRESS=$2
HOSTNAME=$3

QCOW2_FILE_PATH="/var/lib/vz/images/$VM_NUM/vm-${VM_NUM}-disk-1.qcow2"
RAW_FILE_PATH=`echo $QCOW2_FILE_PATH | sed 's/qcow2/raw/g'`
CONFIG_FILE_PATH="/etc/pve/qemu-server/${VM_NUM}.conf"
MOUNT_DIR="/mnt/vm$VM_NUM"

tool_dir=/root/github/cyber_range/server/tools/proxmox
MAX_PART=16

if [ ! -e $QCOW2_FILE_PATH ]; then
    if [ ! -e $RAW_FILE_PATH ]; then
        echo "Image file dose not exist"
        exit 1
    fi
    # TODO: utils以下に移動
    $tool_dir/convert_raw_to_qcow2.sh $RAW_FILE_PATH
    sed -ie "s/raw/qcow2/g" $CONFIG_FILE_PATH
fi

# parted install LVM is need parted
result=`dpkg -l | grep parted`
if [ ${#result} -eq 0 ]; then
    apt-get install -y parted
fi

TENS_PLACE=${VM_NUM:1:1}
#TENS_PLACE=$((TENS_PLACE-1))
ONE_PLACE=${VM_NUM:2:1}
ONE_PLACE=$((ONE_PLACE-1))
NBD_NUM=$(((TENS_PLACE*4 + ONE_PLACE) % MAX_PART))

# ディスクイメージのマウント
$tool_dir/disk_mount.sh $NBD_NUM $QCOW2_FILE_PATH

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
#./nfs_setup.sh $VM_NUM $IP_ADDRESS $PC_TYPE # nfsを利用する場合に実行(現在利用していない)
sync
sync
sync
umount $MOUNT_DIR

# ディスクイメージのアンマウント
$tool_dir/disk_umount.sh $NBD_NUM $NEW_VG_NAME

# マウント用のディレクトリ削除
rmdir $MOUNT_DIR
