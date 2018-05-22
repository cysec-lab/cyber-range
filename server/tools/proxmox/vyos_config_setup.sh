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

QEOW2_FILE_PATH="/var/lib/vz/images/$VM_NUM/vm-${VM_NUM}-disk-1.qcow2"

if [ ! -e $QEOW2_FILE_PATH ]; then
    echo "$QEOW2_FILE_PATH is not exists"
    exit 1
fi

# parted install LVM is need parted
result=`dpkg -l | grep parted`
if [ ${#result} -eq 0 ]; then
    apt-get install -y parted
fi

#TENS_PLACE=${VM_NUM:1:1}
#TENS_PLACE=$((TENS_PLACE-1))
#ONE_PLACE=${VM_NUM:2:1}
#ONE_PLACE=$((ONE_PLACE-1))
#NBD_NUM=$((TENS_PLACE*4 + ONE_PLACE))
NBD_NUM=${VM_NUM:0:1}


modprobe nbd max_part=16

qemu-nbd -c /dev/nbd$NBD_NUM $QEOW2_FILE_PATH
sleep 2
partprobe /dev/nbd$NBD_NUM
mkdir /mnt/vm$VM_NUM
mount /dev/nbd${NBD_NUM}p1 /mnt/vm$VM_NUM
   
# cloneによるPV,VGのUUID副重問題の解決
#pvchange --uuid /dev/nbd${NBD_NUM}p2
#vgrename vg_$TEMPLATE_NAME vg_$VM_NUM      # kernel panicの原因
#vgchange --uuid vg_$VM_NUM
##vgchange -ay vg_$TEMPLATE_NAME
#vgchange -ay vg_$VM_NUM

# VM clone setup
$WORK_DIR/clone_vyos.sh $VM_NUM $VYOS_NETWORK_BRIDGE $GROUP_NETWORK_BRIDGE

# Phisical Volume umount
umount /mnt/vm$VM_NUM

# cleanup
rmdir /mnt/vm$VM_NUM
#vgchange -an vg_$TEMPLATE_NAME
#vgchange -an vg_$VM_NUM
qemu-nbd -d /dev/nbd$NBD_NUM

