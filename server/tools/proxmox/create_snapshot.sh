#!/bin/bash

# Need vmid snapshot_name
if [ $# -ne 2 ]; then
  echo "Need <vmid> <snapname>"
  echo "$0 [100] [vm100_snapshot]"
  exit
fi

VMID=$1
SNAPNAME=$2

result=`cat /etc/pve/qemu-server/${VMID}.conf | grep 'ide0:' | grep 'zfs'`
if [ ${#result} -ne 0 ]; then
    # ZFS
    zfs snapshot rpool/data/vm-${VMID}-disk-1@$SNAPNAME
else
    # QEMU
    qm snapshot $VMID $SNAPNAME
fi
