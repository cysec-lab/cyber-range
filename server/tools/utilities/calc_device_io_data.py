#!/usr/bin/env python3
# coding: UTF-8

import os
import subprocess
import csv
from collections import OrderedDict

home_dir = os.getenv('HOME')

input_file = home_dir + '/io_data_full_convert.txt'
output_file = home_dir + '/io_data_full_average.txt'
csv_file = home_dir + '/io_data_full.csv'

# iostat -dmxt 1 の結果
data_info = ['device', 'rrqm/s', 'wrqm/s', 'r/s', 'w/s', 'rMB/s', 'wMB/s', 'avgrq-sz', 'avgqu-sz', 'await', 'r_await', 'w_await', 'svctm', '%util']

device_table = OrderedDict()
new_line_count = 0

def init_device_table_data(data):
    device_table[data[0]] = [float(d) for d in data[1:]]

def add_device_table_data(data):
    device_name = data[0]
    for idx, num in enumerate(data[1:]):
        device_table[device_name][idx] += float(num)

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

time = new_line_count - 3 # 不要な最初2回の改行と最後の改行1回分を無視する
print("時間" + str(time) + '秒')

# textデータへの書き込み
with open(output_file, 'w', encoding='utf-8') as output_f:
    # data_infoの書き込み
    output_f.write("\t".join(data_info) + "\n")

    # 数字データの書き込み
    for device_name, device_data in device_table.items():
        shape_data = ["{0:.2f}".format(d/time) for d in device_data]
        output_f.write(device_name + "\t" + "\t".join(shape_data) + "\n")
        #print(device_name, shape_data)

# csvへの書き込み
with open(csv_file, 'w', encoding='utf-8') as output_f:
    writer = csv.writer(output_f, lineterminator='\n')

    # data_infoの書き込み
    writer.writerow(data_info)

    # 数字データの書き込み
    for device_name, device_data in device_table.items():
        shape_data = ["{0:.2f}".format(d/time) for d in device_data]
        shape_data.insert(0, device_name)
        writer.writerow(shape_data)

