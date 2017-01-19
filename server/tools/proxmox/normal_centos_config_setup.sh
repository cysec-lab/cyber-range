#!/bin/bash
# TODO cloneテンプレートのVG名の究明（ホスト名?）
#      TEMPLATE_NAMEの変更
# TODO UUID変更は本当に必要ないのかの究明

if [ $# -ne 3 ]; then
    echo "[vm num] [TEMPLATE_NAME] [NBD num]need"
    echo "example:"
    echo "$0 [111] [VolGroup] [0]"
    exit 1
fi

VM_NUM=$1
TEMPLATE_NAME=$2
NBD_NUM=$3
VG_NAME="vg_${VM_NUM}"
MOUNT_DIR="/mnt/vm${VM_NUM}"

mkdir $MOUNT_DIR

# boot config edit grub
mount /dev/nbd${NBD_NUM}p1 $MOUNT_DIR
sed -i -e "s/${TEMPLATE_NAME}/${VG_NAME}/g" "${MOUNT_DIR}/grub/grub.conf"
umount $MOUNT_DIR

# Phisical Volume mount
#mount /dev/vg_$TEMPLATE_NAME/lv_root /mnt/vm$VM_NUM
mount /dev/$VG_NAME/lv_root $MOUNT_DIR

# boot config edit fstab
# TODO UUID change
sed -i -e "s/$TEMPLATE_NAME/$VG_NAME/g" "${MOUNT_DIR}/etc/fstab"

