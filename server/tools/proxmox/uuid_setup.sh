#!/bin/bash

if [ $# -ne 3 ]; then
    echo "[VM num] [old VG name] [new VG name] need"
    echo "example:"
    echo "$0 111 VolGroup vg_111"
    exit 1
fi

VM_NUM=$1
OLD_VG_NAME=$2
NEW_VG_NAME=$3

QEOW2_FILE_PATH="/var/lib/vz/images/$VM_NUM/vm-${VM_NUM}-disk-1.qcow2"
MAX_PART=16

if [ ! -e $QEOW2_FILE_PATH ]; then
    echo "file is not exists"
    exit 1
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


modprobe nbd max_part=$MAX_PART



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
#qemu-nbd -c /dev/nbd$NBD_NUM $QEOW2_FILE_PATH
#partprobe /dev/nbd$NBD_NUM
   
# cloneによるPV,VGのUUID副重問題の解決
pvchange --uuid /dev/nbd${NBD_NUM}p2
vgrename $OLD_VG_NAME $NEW_VG_NAME      # kernel panicの原因
vgchange --uuid $NEW_VG_NAME


#vgchange -ay vg_$TEMPLATE_NAME
##vgchange -ay $VG_NAME
#
##)
## ->排他的制御終了
#
#
#
#mkdir /mnt/vm$VM_NUM
#
## boot config edit grub
#mount /dev/nbd${NBD_NUM}p1 /mnt/vm$VM_NUM
#sed -i -e "s/$TEMPLATE_NAME/$VM_NUM/g" /mnt/vm$VM_NUM/grub/grub.conf
#umount /mnt/vm$VM_NUM
#
## Phisical Volume mount
##mount /dev/vg_$TEMPLATE_NAME/lv_root /mnt/vm$VM_NUM
#mount /dev/$VG_NAME/lv_root /mnt/vm$VM_NUM
#
## boot config edit fstab
## TODO UUID change
##VG_UUID=`vgdisplay $VG_NAME | grep 'VG UUID' | awk '{print $3}'`
##sed -i -e "s/UUID=\w{6}-\w{4}-\w{4}-\w{4}......\t/UUID=$VG_UUID\t/g" /mnt/vm$VM_NUM/etc/fstab
#sed -i -e "s/$TEMPLATE_NAME/$VM_NUM/g" /mnt/vm$VM_NUM/etc/fstab
#
## VM clone setup
#./clone.sh $IP_ADDRESS $PC_TYPE$VM_NUM $VM_NUM
#
## Phisical Volume umount
#umount /mnt/vm$VM_NUM
#
## cleanup
#rmdir /mnt/vm$VM_NUM
##vgchange -an vg_$TEMPLATE_NAME
#vgchange -an $VG_NAME
#qemu-nbd -d /dev/nbd$NBD_NUM
#
