#!/bin/bash

# Need [Data count] [Data size(KB)] 
if [ $# -ne 2 ]; then
    echo "Need [Data count] [Data size(KB)]"
    echo "$0 [100] [1024]"
    exit
fi

dummy_directory=/tmp/dummy_data

NUM=$1
SIZE=$2

# 前のダミーデータを削除
rm -rf $dummy_directory

# ディレクトリの作成 
mkdir -p $dummy_directory

# ダミーデータ作成計測開始
start_time=`date +%s`

# ダミーデータの作成
for ((i = 0; i < $NUM; i++)); do
    dd if=/dev/zero of=$dummy_directory/dummy${i} bs=${SIZE}k count=1
done

# ダミーデータ作成計測終了
end_time=`date +%s`

time=$((end_time - start_time))
echo $time
