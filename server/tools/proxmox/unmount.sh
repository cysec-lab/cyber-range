#!/bin/bash

if [ $# -ne 1 ]; then
	echo 'need [nbd num]'
	exit 1
fi

qemu-nbd -d /dev/nbd$1
