#!/bin/bash

for i in `seq 800 899`
do
    status=`qm status $i`

    if [ "$status" == "status: running" ]; then
        qm stop $i
    fi
done
