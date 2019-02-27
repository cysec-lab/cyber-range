#!/bin/bash

# Proxmox UIで利用できるグループを追加するスクリプト
if [ $# -ne 1 ]; then
    echo "need [Group name]"
    echo "sample:"
    echo "$0 group1"
    exit
fi

group_name=$1

pveum groupadd $group_name
