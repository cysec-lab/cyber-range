#!/bin/sh

FILENAME='/etc/grub.conf'
sed -i -e "s/quiet rhgb/console=ttyS0,115200/g" $FILENAME

ADDSENTENCE="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1\n"
ADDSENTENCE=$ADDSENTENCE"terminal --timeout=5 serial console\n"

# 改行文字の問題解決
echo ${ADDSENTENCE%\\n} | sed -e 's/\\n/\n/g' >> $FILENAME
