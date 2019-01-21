#!/bin/bash

if [ $# -ne 1 ]; then
    echo "run script need"
    echo "example:"
    echo "$0 all_run.sh"
    exit 1
fi

run_script=$1

times=10

if [ ! -e "$1" ]; then
    echo "$run_script is not exist"
    exit 1
fi

for (( i = 0; i < $times; i++)); do
    #bash $run_script
    echo $run_script
done
