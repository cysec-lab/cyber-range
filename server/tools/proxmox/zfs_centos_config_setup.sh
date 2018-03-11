#!/bin/bash
# TODO cloneテンプレートのVG名の究明（ホスト名?）
#      TEMPLATE_NAMEの変更
# TODO UUID変更は本当に必要ないのかの究明
# TODO ファイル分割

if [ $# -ne 4 ]; then
    echo "[vm num] [IP Address] [PC type] [TEMPLATE_NAME] need"
    echo "example:"
    echo "$0 111 192.168.110.11 client"
    exit 1
fi

VM_NUM=$1
IP_ADDRESS=$2
PC_TYPE=$3
TEMPLATE_NAME=$4
VG_NAME="vg_$VM_NUM"

DISK_DATA_DIR="/dev/rpool/data"
DISK_DATA_FILE="$DISK_DATA_DIR/vm-${VM_NUM}-disk-1"
MOUNT_DIR="/mnt/vm$VM_NUM"
NEW_VG_NAME="vg_$VM_NUM"

MAX_PART=16

# ZFS Cloneを待つ
while [ ! -e $DISK_DATA_FILE ]; do
    sleep 1
done

# parted install LVM is need parted
result=`dpkg -l | grep parted`
if [ ${#result} -eq 0 ]; then
    apt-get install parted
fi

TENS_PLACE=${VM_NUM:1:1}
TENS_PLACE=$((TENS_PLACE-1))
ONE_PLACE=${VM_NUM:2:1}
ONE_PLACE=$((ONE_PLACE-2))
NBD_NUM=$(((TENS_PLACE*4 + ONE_PLACE) % MAX_PART))


modprobe nbd max_part=16


# 排他的制御 ->
# flockコマンド
# TODO ロックファイル置きっぱなし
#LOCK_FILE='/tmp/example.lock'
#mkdir $LOCK_FILE

# 参考:http://fj.hatenablog.jp/entry/2016/03/12/223319
#(
#    flock -w 60 || {
#        echo "ERROR: lock timeout" 1>&2
#        exit 1;
#    }
#
# disk image mount
# TODO 同時mountしてしまうとUUID重複で操作が出来なくなる
#      排他制御が必要
qemu-nbd -c /dev/nbd$NBD_NUM -f raw $DISK_DATA_FILE # 拡張子を明示する
sleep 2
partprobe /dev/nbd$NBD_NUM
   
# cloneによるPV,VGのUUID副重問題の解決
TEMP_VG_NAME=`vgdisplay | grep 'VG Name' | awk '{ print $3 }'` # vg_clientscenario1zfs
pvchange --uuid /dev/nbd${NBD_NUM}p2
vgrename $TEMP_VG_NAME $NEW_VG_NAME      # kernel panicの原因
vgchange --uuid $NEW_VG_NAME
vgchange -ay $NEW_VG_NAME

#)
# ->排他的制御終了

mkdir $MOUNT_DIR

# boot config edit grub
#mount $DATA_DIR/vm-${VM_NUM}-disk-1-part1 $MOUNT_DIR 左でもできた
mount /dev/nbd${NBD_NUM}p1 $MOUNT_DIR
sed -i -e "s/$TEMP_VG_NAME/$NEW_VG_NAME/g" $MOUNT_DIR/grub/grub.conf
sync
sync
sync
umount $MOUNT_DIR

# Phisical Volume mount
mount /dev/$VG_NAME/lv_root /mnt/vm$VM_NUM

# boot config edit fstab
# TODO UUID change
#VG_UUID=`vgdisplay vg_$VM_NUM | grep 'VG UUID' | awk '{print $3}'`
#sed -i -e "s/UUID=\w{6}-\w{4}-\w{4}-\w{4}......\t/UUID=$VG_UUID\t/g" /mnt/vm$VM_NUM/etc/fstab
sed -i -e "s/$TEMP_VG_NAME/$NEW_VG_NAME/g" $MOUNT_DIR/etc/fstab

# VM clone setup
$WORK_DIR/clone.sh $VM_NUM $IP_ADDRESS $PC_TYPE$VM_NUM
$WORK_DIR/nfs_setup.sh $VM_NUM $IP_ADDRESS $PC_TYPE

# Phisical Volume umount
sync
sync
sync
umount $MOUNT_DIR
#sleep 5

# cleanup
rmdir $MOUNT_DIR

vgchange -an $NEW_VG_NAME
qemu-nbd -d /dev/nbd$NBD_NUM
