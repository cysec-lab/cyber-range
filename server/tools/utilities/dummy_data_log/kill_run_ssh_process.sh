#!/bin/bash

IFS=$'\n';
while [ "`ps aux | grep 'StrictHostKeyChecking=no' | grep -v 'grep'`" != '' ]; do
    run_ssh_processes=($(ps aux | grep 'StrictHostKeyChecking=no' | grep -v 'grep'))
    for run_ssh_process in ${run_ssh_processes[@]}; do
        process_id=`echo $run_ssh_process | awk '{print $2}'`
        kill -9 $process_id
    done
done
