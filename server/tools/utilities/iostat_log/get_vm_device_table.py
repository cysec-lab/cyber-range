#!/usr/bin/env python3
# coding: UTF-8

# iostat -dmxt 1の結果におけるdevice名とvmを紐付ける
# zfsのデータはzd608のようにdevice名からvmが推測できない
# /dev/rpool/data のリンクによって管理されている

import sys
import os
import subprocess

argvs = sys.argv
if (len(argvs) != 2):
    print('Usage: # python3 %s [clone type]' % argvs[0])
    print('Example: # python3 %s zfs' % argvs[0])
    quit()

clone_type = argvs[1]
if clone_type != 'full' and clone_type != 'zfs':
    print('clone type is full or zfs')
    quit()

home_dir = os.getenv('HOME')

clone_type = argvs[1]

rpool_device_dir = '/dev/rpool/data'
input_file = home_dir + '/io_data_' + clone_type + '.txt'
output_file = home_dir + '/io_data_' + clone_type + '_convert.txt'

device_table = {}

try:
    cmd = 'ls -l {dir}'.format(dir=rpool_device_dir)
    res = subprocess.check_output(cmd.split()).decode('utf-8')

except:
    print("Error")
    exit(1)

res_list = res.split("\n")
for res_line in res_list:
    if 'disk' in res_line and 'part' not in res_line:
        # ls結果を分解 ['lrwxrwxrwx', '1', 'root', 'root', '11', '11月', '26', '16:17', 'vm-101-disk-1', '->', '../../zd608']
        line_split = res_line.split()
        # vm名の取得
        vm_name = line_split[-3][0:-7].replace('-', '') # vm-999-disk-1 を vm999に変更

        # device名の取得
        disk_name = line_split[-1].split('/')[-1]

        device_table[disk_name] = vm_name

with open(input_file, 'r', encoding='utf-8') as input_f:
    f_data = input_f.read()
    for disk_name in device_table.keys():
        f_data = f_data.replace(disk_name, device_table[disk_name])

    with open(output_file, 'w', encoding='utf-8') as output_f:
        output_f.write(f_data)
