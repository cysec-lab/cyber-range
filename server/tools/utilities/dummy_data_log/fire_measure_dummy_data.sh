#!/bin/bash

if [ $# -ne 4 ]; then
    echo "Need [Mode(r or w)] [Interval] [Clone Type] [Loop times]"
    echo "$0 [r] [32] [zfs] [3]"
    exit
fi

VMS=(103 203 303 403 503 603)

MODE=$1
INTERVAL=$2
CLONE_TYPE=$3
LOOP_TIMES=$4

current_dir='/root/github/cyber_range/server/tools/utilities/dummy_data_log/data/loop'

dir="${current_dir}/${MODE}_${INTERVAL}_${CLONE_TYPE}_${LOOP_TIMES}/"
mkdir -p $dir


for vm in ${VMS[@]}; do
    ssh -o StrictHostKeyChecking=no root@192.168.11${vm:0:1}.3 "/root/measure_dummy_data.sh $MODE $INTERVAL $CLONE_TYPE" &
done

while [ "`ps aux | grep 'StrictHostKeyChecking=no' | grep -v 'grep'`" != '' ]; do
    # 何も処理をしない
    :
done

for ((i = 1; i <= ${#VMS[@]}; i++)); do
    scp -o StrictHostKeyChecking=no 192.168.11${i}.3:/root/mea\*.txt $dir
    for file in `\find $dir -maxdepth 1 -type f -name "*.txt"`; do
        new_file="${file%.*}_${i}.log"
        mv $file $new_file
    done
done
