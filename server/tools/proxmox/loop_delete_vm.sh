#!/bin/bash

if [ $# -ne 2 ]; then
    echo "[VM NUM] [Loop Count] need"
    echo "example:"
    echo "$0 400 5"
    exit 1
fi

VM_NUM=$1
LOOP_COUNT=$2

# delete
for i in `seq 1 $LOOP_COUNT`
do
    delete_num=`expr $VM_NUM + $i - 1`
#    ./delete_vm.sh $delete_num &
done
