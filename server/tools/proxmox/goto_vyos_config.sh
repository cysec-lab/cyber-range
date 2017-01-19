#!/bin/bash
# TODO cloneテンプレートのVG名の究明（ホスト名?）
#      TEMPLATE_NAMEの変更
# TODO UUID変更は本当に必要ないのかの究明

if [ $# -ne 3 ]; then
    echo "[vm num] [IP Address] [TEMPLATE_NAME] need"
    echo "example:"
    echo "$0 111 192.168.100.221 vyos"
    exit 1
fi

VM_NUM=$1
IP_ADDRESS=$2
TEMPLATE_NAME=$3 # 使っていない

QEOW2_FILE_PATH="/var/lib/vz/images/$VM_NUM/vm-${VM_NUM}-disk-1.qcow2"

if [ ! -e $QEOW2_FILE_PATH ]; then
    echo "file is not exists"
    exit 1
fi

# parted install LVM is need parted
apt-get install parted

NBD_NUM=${VM_NUM:2:1}

modprobe nbd max_part=16

qemu-nbd -c /dev/nbd$NBD_NUM $QEOW2_FILE_PATH
partprobe /dev/nbd$NBD_NUM
mkdir /mnt/vm$VM_NUM
mount /dev/nbd${NBD_NUM}p1 /mnt/vm$VM_NUM
   
# VM clone setup
#./clone_vyos.sh $VM_NUM

VM_NUM=$1
Proxmox_side_IP_ADDRESS="192.168.100.$VM_NUM"
VyOS_side_NETWORK="192.168.1${VM_NUM2:1}0"
MOUNT_DIR="/mnt/vm$VM_NUM"

CONFIG_FILE="$MOUNT_DIR/boot/1.1.7/live-rw/config/"
cd $CONFIG_FILE
echo $CONFIG_FILE

#sed -i -e "s/192.168.100.222/$Proxmox_side_IP_ADDRESS/g" $CONFIG_FILE
#echo $Proxmox_side_IP_ADDRESS
#sed -i -e "s/192.168.110/$VyOS_side_NETWORK/g" $CONFIG_FILE
#echo $VyOS_side_NETWORK
#
#
## Phisical Volume umount
#umount /mnt/vm$VM_NUM
#
## cleanup
#rmdir /mnt/vm$VM_NUM
##vgchange -an vg_$TEMPLATE_NAME
##vgchange -an vg_$VM_NUM
#qemu-nbd -d /dev/nbd$NBD_NUM
#
