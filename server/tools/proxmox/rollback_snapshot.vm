#!/bin/bash

# Need vmid snapshot_name
if [ $# -ne 2 ]; then
  echo "Need <vmid> <snapname>"
  echo "$0 [100] [vm100_snapshot]"
  exit
fi

VMID=$1
SNAPNAME=$2

# 注意: 2世代前にrollbackすることは出来ない. 以下のエラーがでる
# can't rollback, more recent snapshots exist
qm rollback $VMID $SNAPNAME
