#!/bin/bash
# dummyデータの 読み取り or 書き込み 時間を計測

if [ $# -ne 3 ]; then
    echo "Need [Mode(r or w)] [Interval] [Clone Type]"
    echo "$0 [r] [32] [zfs]"
    exit
fi

MODE=$1
INTERVAL=$2
CLONE_TYPE=$3

dummy_directory=/tmp/dummy_data
time_array=()

# ディレクトリの移動
cd $dummy_directory

# ダミーデータ作成計測開始
start_time=`date +%s`

i=0
if [ "$MODE" = 'r' ]; then
    for file in `\find . -maxdepth 1 -type f`; do
        cat $file
        # 時間格納
        if [ $(( i % $INTERVAL )) = 0 ]; then
            interval_time=`date +%s`
            time=$((interval_time - start_time))
            time_array+=($time)
        fi
        i=$(( i + 1 ))
    done
elif [ "$MODE" = 'w' ]; then
    for file in `\find . -maxdepth 1 -type f`; do
        echo "$start_time" >> $file
        # 時間格納
        if [ $(( i % $INTERVAL )) = 0 ]; then
            interval_time=`date +%s`
            time=$((interval_time - start_time))
            time_array+=($time)
        fi
        i=$(( i + 1 ))
    done
else
    echo 'invalid arguments'
    exit 1
fi

end_time=`date +%s`

time=$((end_time - start_time))
echo $time

cat << EOT >> "/root/measure_dummy_data_${MODE}_${INTERVAL}_${CLONE_TYPE}_${i}.txt"
${time_array[@]}
$MODE
$INTERVAL
$CLONE_TYPE
${time}s
EOT
