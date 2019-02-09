#!/bin/bash

# Need vmid snapshot_name
if [ $# -ne 2 ]; then
  echo "Need <vmid> <snapname>"
  echo "$0 [100] [vm100_snapshot]"
  exit
fi

VMID=$1
SNAPNAME=$2

zfs snapshot rpool/data/vm-${VMID}-disk-1@$SNAPNAME
