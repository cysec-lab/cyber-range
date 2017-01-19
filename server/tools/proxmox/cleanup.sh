#!/bin/bash
# TODO cloneテンプレートのVG名の究明（VM名?）
#      vgrenameの引数への渡し方
#      応急処置でtestで用いるvg_web713を使用
# TODO 設定を変更するとVM操作が出来ない問題

if [ $# -ne 1 ]; then
    echo "[vm num] need"
    echo "example:"
    echo "$0 111"
    exit 1
fi

VM_NUM=$1
#QEOW2_FILE_PATH="/var/lib/vz/images/$VM_NUM/vm-${VM_NUM}-disk-1.qcow2"
#
#if [ ! -e $QEOW2_FILE_PATH ]; then
#    echo "file is not exists"
#    exit 1
#fi

# parted install LVM is need parted
# apt-get install parted

TENS_PLACE=${VM_NUM:1:1}
TENS_PLACE=$((TENS_PLACE-1))
ONE_PLACE=${VM_NUM:2:1}
ONE_PLACE=$((ONE_PLACE-1))
NBD_NUM=$((TENS_PLACE*4 + ONE_PLACE))
NBD_NUM=13

# disk image mount
# TODO 同時mountしてしまうとUUID服従で操作が出来なくなる
#      排他制御が必要
#modprobe nbd max_part=16
#qemu-nbd -c /dev/nbd$NBD_NUM $QEOW2_FILE_PATH
#partprobe /dev/nbd$NBD_NUM
#
## cloneによるPV,VGのUUID副重問題の解決
#pvchange --uuid /dev/nbd${NBD_NUM}p2
#vgrename vg_web713 vg_$VM_NUM
#
## Phisical Volume  mount
#vgchange -ay vg_$VM_NUM
#mkdir /mnt/vm$VM_NUM
#mount /dev/vg_$VM_NUM/lv_root /mnt/vm$VM_NUM
#cd /mnt/vm$VM_NUM
#
# VM clone setup
#./clone.sh $IP_ADDRESS $PC_TYPE$VM_NUM $VM_NUM
#
## cleanup
umount /mnt/vm$VM_NUM
rmdir /mnt/vm$VM_NUM
vgchange -an vg_$VM_NUM
qemu-nbd -d /dev/nbd$NBD_NUM
#
