# iostatの出力結果をコンバートスクリプト
iostat -dmxt 1 を実行している
## スクリプトの簡単な説明
### ZFSクローンではデバイスとVMとの関係が分からないので、紐付けるスクリプト
get_vm_device_table.py
### データをもとに負荷の平均を求めるスクリプト
calc_device_io_data.py
### データをもとに毎秒ごとにVMごとの負荷を求めるスクリプト
transition_device_io_data.py

## 使い方
### 負荷の平均を求めたい場合
python3 get_vm_device_table zfs
python3 calc_device_io_data zfs
### VMごとの平均の負荷を求める場合
python3 get_vm_device_table zfs
python3 transition_device_io_data zfs
