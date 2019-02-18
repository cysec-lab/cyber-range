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

# cloneによるPV,VGのUUID副重問題の解決
OLD_VG_NAME=`vgdisplay | grep 'VG Name' | grep -v 'pve' | awk '{ print $3 }'`
NEW_VG_NAME="vg_$VM_NUM"
pvchange --uuid /dev/nbd${NBD_NUM}p2
vgrename $OLD_VG_NAME $NEW_VG_NAME      # kernel panicの原因
vgchange --uuid $NEW_VG_NAME
vgchange -ay $NEW_VG_NAME


mkdir $MOUNT_DIR

# boot config edit grub
#mount $DATA_DIR/vm-${VM_NUM}-disk-1-part1 $MOUNT_DIR 左でもできた
mount /dev/nbd${NBD_NUM}p1 $MOUNT_DIR
sed -i -e "s/$OLD_VG_NAME/$NEW_VG_NAME/g" $MOUNT_DIR/grub/grub.conf
sync
sync
sync
umount $MOUNT_DIR

# Phisical Volume mount
mount /dev/$NEW_VG_NAME/lv_root /mnt/vm$VM_NUM

# boot config edit fstab
# TODO UUID change
#VG_UUID=`vgdisplay vg_$VM_NUM | grep 'VG UUID' | awk '{print $3}'`
#sed -i -e "s/UUID=\w{6}-\w{4}-\w{4}-\w{4}......\t/UUID=$VG_UUID\t/g" /mnt/vm$VM_NUM/etc/fstab
sed -i -e "s/$OLD_VG_NAME/$NEW_VG_NAME/g" $MOUNT_DIR/etc/fstab

# VM clone setup
$tool_dir/clone.sh $VM_NUM $IP_ADDRESS $HOSTNAME
#$tool_dir/nfs_setup.sh $VM_NUM $IP_ADDRESS $PC_TYPE

# Phisical Volume umount
sync
sync
sync
umount $MOUNT_DIR

# cleanup
rmdir $MOUNT_DIR

vgchange -an $NEW_VG_NAME
qemu-nbd -d /dev/nbd$NBD_NUM

# 排他制御終了
#rm -rf $LOCK_FILE
