#!/bin/bash

# Proxmox UIで利用できるユーザのVMの追加
if [ $# -ne 2 ]; then
    echo "need [User name] [VM ID]"
    echo "sample:"
    echo "$0 student 111"
    exit
fi

user_id=$1@pve
vm_id=$2

# $vm_id 番のVMをユーザが見れる(操作できる)ようにPermission付与
pveum aclmod /vms/$vm_id -user $user_id -role PVEVMUser

# アクセスを禁止したい場合は以下のコマンドを使う
#pveum aclmod /vms/$vm_id -user $user_id -role NoAccess
