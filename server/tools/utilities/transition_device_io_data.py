#!/usr/bin/env python3
# coding: UTF-8

# デバイスごとの毎秒のデータ推移グラフ

import os
import subprocess
import csv
from collections import OrderedDict
from datetime import datetime

now_time = datetime.now().strftime("%Y%m%d_%H%M%S")

home_dir = os.getenv('HOME')
output_dir = home_dir + '/data/full/'+ now_time
txt_dir = output_dir + '/txt'
csv_dir = output_dir + '/csv'

# 出力先ディレクトリの作成
os.makedirs(output_dir)
os.mkdir(txt_dir)
os.mkdir(csv_dir)

input_file = home_dir + '/io_data_full_convert.txt'
output_file = txt_dir + '/io_data_full_average'
csv_file = csv_dir + '/io_data_full'

# iostat -dmxt 1 の結果
data_info = ['device', 'rrqm/s', 'wrqm/s', 'r/s', 'w/s', 'rMB/s', 'wMB/s', 'avgrq-sz', 'avgqu-sz', 'await', 'r_await', 'w_await', 'svctm', '%util']

device_table = OrderedDict()
new_line_count = 0

def init_device_table_data(data):
    device_table[data[0]] = []
    add_device_table_data(data)

def add_device_table_data(data):
    device_table[data[0]].append([float(d) for d in data[1:]])

with open(input_file, 'r', encoding='utf-8') as input_f:
    for line in input_f:
        if line == "\n":
            new_line_count += 1
            continue

        # 1回目の改行までは不要なデータで、2回目の改行までのデータは起動してからの通算IO情報なので無視する
        if new_line_count < 2:
            continue

        # 不要な情報のとき
        if 'Device' in line or '年' in line:
            continue

        line_split = line.split()
        device_name = line_split[0]
        if device_name in device_table.keys():
            add_device_table_data(line_split)
        else:
            init_device_table_data(line_split)


for device_name, device_data in device_table.items():
    # textデータへの書き込み
    output_file_name = output_file + '_' + device_name + '.txt'
    with open(output_file_name, 'w', encoding='utf-8') as output_f:
        # data_infoの書き込み
        output_f.write("\t".join(data_info) + "\n")

        # 数字データの書き込み
        for data in device_data:
            shape_data = ["{0:.2f}".format(d) for d in data]
            output_f.write(device_name + "\t" + "\t".join(shape_data) + "\n")
            #print(device_name, shape_data)

    # csvへの書き込み
    csv_file_name = csv_file + '_' + device_name + '.csv'
    with open(csv_file_name, 'w', encoding='utf-8') as output_f:
        writer = csv.writer(output_f, lineterminator='\n')

        # data_infoの書き込み
        writer.writerow(data_info)

        # 数字データの書き込み
        for data in device_data:
            shape_data = ["{0:.2f}".format(d) for d in data]
            shape_data.insert(0, device_name)
            writer.writerow(shape_data)

