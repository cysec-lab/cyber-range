#!/bin/bash

if [ $# -ne 5 ]; then
    echo "Need [Mode(r or w)] [Interval] [Clone Type] [Loop times] [Start Date]"
    echo "$0 [r] [32] [zfs] [3] [20190121_130510]"
    exit
fi

VMS=(103 203 303 403 503 603)

IFS=$'\n' # スペースを区切り文字としないようにする

MODE=$1
INTERVAL=$2
CLONE_TYPE=$3
LOOP_TIMES=$4
START_DATE=$5

current_dir='/root/github/cyber_range/server/tools/utilities/dummy_data_log/data/loop'

dir="${current_dir}/${START_DATE}/${MODE}_${INTERVAL}_${CLONE_TYPE}_${LOOP_TIMES}/"
mkdir -p $dir


start_time=`date +%s`
for vm in ${VMS[@]}; do
    ssh -o StrictHostKeyChecking=no root@192.168.11${vm:0:1}.3 "/root/measure_dummy_data.sh $MODE $INTERVAL $CLONE_TYPE" &
done

while [ "`ps aux | grep 'StrictHostKeyChecking=no' | grep -v 'grep'`" != '' ]; do
    end_time=`date +%s`
    time=$((end_time - start_time))
    if [ $time -gt 600 ]; then
        # 死んでいないプロセスを強制的に削除
        run_ssh_processes=($(ps aux | grep 'StrictHostKeyChecking=no' | grep -v 'grep'))
        for run_ssh_process in ${run_ssh_processes[@]}; do
            process_id=`echo $run_ssh_process | awk '{print $2}'`
            kill -9 $process_id
        done
    fi
done

for ((i = 1; i <= ${#VMS[@]}; i++)); do
    scp -o StrictHostKeyChecking=no 192.168.11${i}.3:/root/mea\*.txt $dir
    for file in `\find $dir -maxdepth 1 -type f -name "*.txt"`; do
        new_file="${file%.*}_${i}.log"
        mv $file $new_file
    done
done
