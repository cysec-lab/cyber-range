#!/usr/bin/env python3
# coding: UTF-8

import sys
import os
import csv

dump_data = [[0, 0]]

argvs = sys.argv
if (len(argvs) != 2):
    print('Usage: # python3 %s [FILE PATH]' % argvs[0])
    print('Example: # python3 %s ./measure_dummy_data.txt' % argvs[0])
    quit()

input_file = argvs[1]
if not os.path.isfile(input_file):
    print(input_file + "is not exist")
    quit()

# ファイル読み込み
with open(input_file, 'r', encoding='utf-8') as input_f:
    time_array = input_f.readline().split()
    # 以下のデータは使っていない
    mode       = input_f.readline()
    interval   = int(input_f.readline())
    clone_type = input_f.readline()
    time       = input_f.readline()

    # 2次元配列に変形
    i=interval
    for time in time_array:
        data = [i, int(time)]
        dump_data.append(data)
        i += interval

# csvへの書き込み
csv_file = input_file.replace('txt', 'csv')
with open(csv_file, 'w', encoding='utf-8') as output_f:
    writer = csv.writer(output_f, lineterminator='\n')
    writer.writerows(dump_data)
