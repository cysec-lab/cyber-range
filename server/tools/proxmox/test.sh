#!/bin/bash
#TODO VM IPアドレス

#echo $0
#
#if [ $# -ne 3 ]; then
#    echo "[PC TYPE] [TEMPLATE_NUM] [VM NUM]  need"
#    echo "example:"
#    echo "$0 web 719 111"
#    exit 1
#fi
#
#echo $1
TEMPLATE_NUM=$1
SNAPSHOT=rpool/data/vm-${TEMPLATE_NUM}-disk-1@${TEMPLATE_NUM}_snapshot
cmd="zfs list -r -t snapshot -o name,creation rpool"
eval "$cmd | grep $SNAPSHOT > /dev/null"

if [ $? -ne 0 ]; then
    echo "unmatch"
else
    echo "match"
fi

eval "$cmd"

#eval "$cmd | grep $SNAPSHOT"
#echo $SNAPSHOT
