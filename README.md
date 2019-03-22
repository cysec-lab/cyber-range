# サイバーレンジ

サイバーレンジ演習環境を展開する上で必要となるツール郡

## Description

ZFS or FULLクローンなどクローンタイプ選択可能な演習環境展開スクリプト
個々のVMのディスクイメージに直接アクセスを行い設定変更を行う
各サーバの環境変数(PROXMOX_NUM)による各サーバ内ネットワークの分離

## Features

- `build_environment/json_files` 以下にあるJSONファイルによる設定の管理
- ZFS/FULL 両方のクローン方法への対応

## Requirement

- Proxmox環境(https://pve.proxmox.com/wiki/Main_Page)
- jq

## Usage

1. 演習環境展開の設定

  1. 基礎情報の設定

  `build_environment/json_files/scenario_info.json` の `group_num` と `student_per_group` を設定する．

  2. シナリオの設定

  `build_environment/json_files/scenario_info.json` の `day` と `dayX(Xは数値)` の `scenario_num` を確認する．
    dayを1とするとday1のシナリオ分の演習環境展開が行われる

2. 演習環境展開スクリプトの実行

演習環境構築スクリプトのディレクトリに移動し，スクリプトを実行する

    $ cd ~/github/cysec-lab/cyber-range/build_environment/
    $ bash ./cyber_range_all_scenario_setup.sh

## Author

[@hedgehoCrow](https://github.com/hedgehoCrow)
