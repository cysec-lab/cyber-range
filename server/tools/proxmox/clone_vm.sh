#!/bin/sh

if [ $# -ne 3 ]; then
    echo "tempalte name & template num & new vm num need"
    echo "example:"
    echo "./clone_vm.sh web 111 222"
    exit 1
fi

#TEMPLATE_NAME='web'
#TEMPLATE_NUM='414'
#CLONE_NUM='464'

TEMPLATE_NAME=$1
TEMPLATE_NUM=$2
CLONE_NUM=$3

qm clone $TEMPLATE_NUM $CLONE_NUM --name $TEMPLATE_NAME$CLONE_NUM

qm start $CLONE_NUM

