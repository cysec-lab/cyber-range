#!/bin/bash

if [ $# -ne 2 ]; then
    echo "[vm num] [nbd num] need"
    echo "example:"
    echo "./mount.sh 411 5"
    exit 1
fi

FILE_PATH="/var/lib/vz/images/$1/vm-$1-disk-1.qcow2"

if [ ! -e $FILE_PATH ]; then
    echo "file is not exists"
    exit 1
fi

# parted install LVM is need parted
#result=`dpkg -l | grep parted`
#if [ ${#result} -eq 0 ]; then
#    apt-get install -y parted
#fi


#tens_place=${1:1:1}
#tens_place=$((tens_place-1))
#one_place=${1:2:1}
#one_place=$((one_place-1))
#nbd_num=$((tens_place*4 + one_place))
nbd_num=$2

modprobe nbd max_part=16
qemu-nbd -c /dev/nbd$nbd_num $FILE_PATH

partprobe /dev/nbd$nbd_num

#mount /dev/VolGrup/lv_root /mnt/tmp/$1

# mount
#mkdir /mnt/vm$1
#mount /dev/nbd$nbd_num  /mnt/vm$1


# cleanup
#umount /mnt/$1
#vgchange -an group名
#qemu-nbd -d /dev/nbd$nbd_num



