#!/bin/sh

# ASLRの有効(on) or 無効(off)の引数が必要
if [ $# -ne 1 ]; then
  echo "Need status"
  echo "$0 off"
  exit 1
fi

status=$1

command='sysctl -w kernel.randomize_va_space='

if [ "$status" = 'on' ]; then
    ${command}2
elif [ "$status" = 'off' ]; then
    ${command}0
else
    echo 'invalid args'
    exit 1
fi
