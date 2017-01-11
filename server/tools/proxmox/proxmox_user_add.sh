#!/bin/bash

if [ $# -ne 2 ]; then
    echo "need [PC type] [VM num]"
    echo "sample:"
    echo "$0 client 111"
    exit
fi

if [ $1 = 'client' or $1 = 'web' ]; then
    pveum useradd $1$2@pve
    pveum passwd $1$2@pve
    #TODO except

else
    echo "PC type is client or web"
    exit 1
fi
