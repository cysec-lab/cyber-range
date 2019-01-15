#!/usr/bin/env python3
# coding: UTF-8

import sys
import os
import csv

import pandas as pd
import matplotlib.pyplot as plt

argvs = sys.argv
if (len(argvs) != 2):
    print('Usage: # python3 %s [FILE PATH]' % argvs[0])
    print('Example: # python3 %s ./measure_dummy_data.csv' % argvs[0])
    quit()

input_file = argvs[1]
if not os.path.isfile(input_file):
    print(input_file + "is not exist")
    quit()

# ファイル読み込み
df = pd.read_csv(input_file, encoding="utf-8", names=['files', 'time'])
plt.plot(df['files'], df['time'], marker="o")

output_file = input_file.replace('csv', 'png')
plt.savefig(output_file)
plt.show()

