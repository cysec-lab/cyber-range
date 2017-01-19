#!/bin/bash

for i in `seq 310 345`
do
    status=`qm status $i`

    if [ "$status" == "status: running" ]; then
        ./delete_vm.sh $i &
    fi
done
