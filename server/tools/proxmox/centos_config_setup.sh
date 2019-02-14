#!/bin/bash

if [ $# -ne 5 ]; then
    echo "[VM num] [IP Address] [PC type] [OLD VG name] [NEW VG name] need"
    echo "example:"
    echo "$0 111 192.168.110.11 client VolGroup vg_111"
    exit 1
fi

VM_NUM=$1
IP_ADDRESS=$2
PC_TYPE=$3
OLD_VG_NAME=$4
NEW_VG_NAME=$5

tool_dir=/root/github/cyber_range/server/tools/proxmox
QEOW2_FILE_PATH="/var/lib/vz/images/$VM_NUM/vm-${VM_NUM}-disk-1.qcow2"
RAW_FILE_PATH=`echo $QEOW2_FILE_PATH | sed 's/qcow2/raw/g'`
CONFIG_FILE_PATH="/etc/pve/qemu-server/${VM_NUM}.conf"
MAX_PART=16

if [ ! -e $QEOW2_FILE_PATH ]; then
    if [ ! -e $RAW_FILE_PATH ]; then
        echo "Image file dose not exist"
        exit 1
    fi
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


#modprobe nbd max_part=16



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
#   
## cloneによるPV,VGのUUID副重問題の解決
#pvchange --uuid /dev/nbd${NBD_NUM}p2
#vgrename vg_$TEMPLATE_NAME vg_$VM_NUM      # kernel panicの原因
#vgchange --uuid vg_$VM_NUM
##vgchange -ay vg_$TEMPLATE_NAME
vgchange -ay $NEW_VG_NAME

#)
# ->排他的制御終了

mkdir /mnt/vm$VM_NUM

# boot config edit grub
mount /dev/nbd${NBD_NUM}p1 /mnt/vm$VM_NUM
sed -i -e "s/$OLD_VG_NAME/$NEW_VG_NAME/g" /mnt/vm$VM_NUM/grub/grub.conf
sync
sync
sync
umount /mnt/vm$VM_NUM

# Phisical Volume mount
mount /dev/$NEW_VG_NAME/lv_root /mnt/vm$VM_NUM

# boot config edit fstab
# TODO UUID change
#VG_UUID=`vgdisplay vg_$VM_NUM | grep 'VG UUID' | awk '{print $3}'`
#sed -i -e "s/UUID=\w{6}-\w{4}-\w{4}-\w{4}......\t/UUID=$VG_UUID\t/g" /mnt/vm$VM_NUM/etc/fstab
sed -i -e "s/$OLD_VG_NAME/$NEW_VG_NAME/g" /mnt/vm$VM_NUM/etc/fstab

# VM clone setup
$tool_dir/clone.sh $VM_NUM $IP_ADDRESS $PC_TYPE$VM_NUM
#./nfs_setup.sh $VM_NUM $IP_ADDRESS $PC_TYPE

#./disk_umount.sh $VM_NUM $IP_ADDRESS $PC_TYPE $TEMPLATE_NAME
#qm start $VM_NUM


# Phisical Volume umount
#umount /mnt/vm$VM_NUM
#
## cleanup
#rmdir /mnt/vm$VM_NUM
##vgchange -an vg_$TEMPLATE_NAME
#vgchange -an vg_$VM_NUM
#qemu-nbd -d /dev/nbd$NBD_NUM
