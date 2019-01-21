#!/bin/bash

if [ $# -ne 5 ]; then
    echo "Need [Mode(r or w)] [Interval] [Clone Type] [Loop times] [Data Path]"
    echo "$0 [r] [32] [zfs] [3] [cybar_range/server/tools/utilities/dummy_data_log/data/loop/20190119_210510]"
    exit
fi

MODE=$1
INTERVAL=$2
CLONE_TYPE=$3
LOOP_TIMES=$4
DATA_PATH=$5

for ((i = 0; i < $LOOP_TIMES; i++)); do
  work_dir="${DATA_PATH}/${MODE}_${INTERVAL}_${CLONE_TYPE}_${i}/"
  j=0
  total_run_time=0
  for file in `\find $work_dir -maxdepth 1 -type f -name "*.log" -not -name "*result*"`; do
    run_time=`tail -1 $file`
    run_time=${run_time%s}
    total_run_time=$((total_run_time + run_time))
    j=$((j + 1))
  done
  if [ "$j" = '0' ]; then
    echo "$work_dir is not files"
  else
    result_file=${file%\_*}_result.log
    average=`echo "scale=5; $total_run_time / $j" | bc | sed -e 's/^\./0./g'`
    echo $average > $result_file
  fi
done
