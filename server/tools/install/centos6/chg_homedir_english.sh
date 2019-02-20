#!/bin/bash
# ホームディレクトリの名前を日本語 -> 英語に変更
# GUI環境上で実行する必要あり

if [ ! -e '/root/デスクトップ' ]; then
    echo 'デスクトップディレクトリが存在していません'
    exit 1
fi

LANG=C xdg-user-dirs-gtk-update
