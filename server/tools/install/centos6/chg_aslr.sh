#!/bin/sh
# 参考:https://askubuntu.com/questions/318315/how-can-i-temporarily-disable-aslr-address-space-layout-randomization

# ASLRの有効(on) or 無効(off)の引数が必要
if [ $# -ne 1 ]; then
  echo "Need status"
  echo "$0 off"
  exit 1
fi

status=$1

if [ "$status" = 'on' ]; then
    value=2
elif [ "$status" = 'off' ]; then
    value=0
else
    echo 'invalid args'
    exit 1
fi

echo "kernel.randomize_va_space = $value" > /etc/sysctl.d/01-disable-aslr.conf
