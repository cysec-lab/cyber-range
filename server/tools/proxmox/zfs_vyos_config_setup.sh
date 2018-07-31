#!/bin/bash
# TODO cloneテンプレートのVG名の究明（ホスト名?）
#      TEMPLATE_NAMEの変更
# TODO UUID変更は本当に必要ないのかの究明

if [ $# -ne 3 ]; then
    echo "[vm num] [VYOS_NETWORK_BRIDGE] [GROUP_NETWORK_BRIDGE] need"
    echo "example:"
    echo "$0 111 1 132"
    exit 1
fi

VM_NUM=$1
VYOS_NETWORK_BRIDGE=$2
GROUP_NETWORK_BRIDGE=$3

MAX_PART=16
DISK_DATA_DIR="/dev/rpool/data"
DISK_DATA_FILE="$DISK_DATA_DIR/vm-${VM_NUM}-disk-1"

tool_dir=/root/github/cyber_range/server/tools/proxmox

# ZFS Cloneが終わるのを待つ
if [ ! -e $DISK_DATA_FILE ]; then
    sleep 1
fi

# parted install LVM is need parted
result=`dpkg -l | grep parted`
if [ ${#result} -eq 0 ]; then
    apt-get install -y parted
fi
modprobe nbd max_part=16

HANDRED_NUM=${VM_NUM:0:1}
HANDRED_NUM=$((HANDRED_NUM-1))
#TENS_NUM=${VM_NUM:1:1}
#TENS_PLACE=$((TENS_PLACE-1))
ONE_PLACE=${VM_NUM:2:1}
ONE_PLACE=$((ONE_PLACE-1))
NBD_NUM=$(((HANDRED_NUM*6 + ONE_NUM) % MAX_PART))

# 排他制御
#LOCK_FILE="/tmp/nbd${NBD_NUM}.lock"
#lockfile $LOCK_FILE

qemu-nbd -c /dev/nbd$NBD_NUM -f raw $DISK_DATA_FILE
sleep 2
partprobe /dev/nbd$NBD_NUM
mkdir /mnt/vm$VM_NUM
mount /dev/nbd${NBD_NUM}p1 /mnt/vm$VM_NUM
   
# VM clone setup
$tool_dir/clone_vyos.sh $VM_NUM $VYOS_NETWORK_BRIDGE $GROUP_NETWORK_BRIDGE

# Phisical Volume umount
umount /mnt/vm$VM_NUM

# cleanup
rmdir /mnt/vm$VM_NUM
#vgchange -an vg_$TEMPLATE_NAME
#vgchange -an vg_$VM_NUM
qemu-nbd -d /dev/nbd$NBD_NUM

# 排他制御終了
#rm -rf $LOCK_FILE
