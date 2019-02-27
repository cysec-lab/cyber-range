#!/bin/bash

# Proxmox UIで利用できるユーザの追加スクリプト
if [ $# -ne 2 ]; then
    echo "need [User name] [Password]"
    echo "sample:"
    echo "$0 student1 12345678"
    exit
fi

user_id=$1@pve
password=$2

pveum useradd $user_id
pvesh set /access/password --userid $user_id --password $password
