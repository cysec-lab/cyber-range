#!/bin/bash

# ユーザ名とパスワードの引数が必要
if [ $# -ne 2 ]; then
  echo "Need [User name] [Password]"
  echo "$0 newuser password"
  exit 1
fi

USER_NAME=$1
PASSWORD=$2

if [ "$USER_NAME" = 'root' ]; then
    echo "can't change root password"
    exit 1
fi

CONF_FILE='/etc/shadow'

# ユーザ情報の取得
USER_INFO=`grep $USER_NAME $CONF_FILE`

if [ "$USER_INFO" = '' ]; then
    echo "$USER_NAME user is not exist"
    exit 1
fi

# saltの抽出
salt=${USER_INFO%\$*}
salt=${salt#*:}
salt=${salt//\$/\\\$} # 特殊文字をエスケープ

# パスワードのハッシュ化 sha512
hashed_passwd=$(perl -e "print crypt(\"$PASSWORD\", \"$salt\");")
hashed_passwd=${hashed_passwd//\//\\/} # 特殊文字をエスケープ

# 置換
sed -ie "s/^$USER_NAME:[^:]*:/$USER_NAME:$hashed_passwd:/" $CONF_FILE
