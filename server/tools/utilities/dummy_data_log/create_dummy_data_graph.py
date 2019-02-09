#!/usr/bin/env python3
# coding: UTF-8

import sys
import os
import csv

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

title     = 'ZFSクローンとFULLクローンのモデル化'
x_label   = 'ファイル数[個]'
y_label   = '時間[秒]'
diff_time = 38 # ZFSクローンとFULLクローンの時間差[s]

argvs = sys.argv
if (len(argvs) != 3):
    print('Usage: # python3 %s [ZFS FILE PATH] [FULL FILE PATH]' % argvs[0])
    print('Example: # python3 %s ./measure_dummy_zfs_data.csv ./measure_dummy_full_data.csv' % argvs[0])
    quit()

zfs_file  = argvs[1]
full_file = argvs[2]
if not os.path.isfile(zfs_file) or not os.path.isfile(full_file):
    print(zfs_file + " or "+ full_file + " are not exist")
    quit()

# ファイル読み込み
df_zfs  = pd.read_csv(zfs_file, encoding="utf-8", names=['files', 'time'])
df_full = pd.read_csv(full_file, encoding="utf-8", names=['files', 'time'])

# クローン時間の差分ゲタをはかす
df_full = df_full + np.array([0, diff_time])

# データをプロット
plt.plot(df_zfs['files'], df_zfs['time'], label="zfs")
plt.plot(df_full['files'], df_full['time'], label="full")

# プロットの設定
plt.legend() # 凡例をグラフにプロット
plt.title(title)
plt.xlabel(x_label)
plt.ylabel(y_label)
plt.xlim(left=0)
plt.ylim(bottom=0)

# ファイル出力と表示
output_dir, output_file  = os.path.split(zfs_file)
output_dir = output_dir.replace('zfs', '')
#output_file = output_file.replace('zfs_', '').replace('csv', 'png')                                # ゲタを履かせない結果のファイル名
output_file = output_file.replace('zfs_', '').replace('data', 'data_inflate').replace('csv', 'png') # ゲタを履かせた結果のファイル名
plt.savefig(output_dir + output_file)
plt.show()

