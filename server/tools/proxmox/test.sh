#!/bin/bash

start_time=`date +%s`

PC_TYPE='web'
CLIENT_NUM=(611 612 613)
WEB_NUM=(614 624 634 644)
clone_pid=()

for num in ${CLIENT_NUM[@]}; do
    ./clone_vm.sh 'client' 599 $num &
    pid=$!
    clone_pid+=($pid)
    sleep 1
done

#for num in ${WEB_NUM[@]}; do
#    ./clone_vm.sh 'web' 600 $num &
#    pid=$!
#    clone_pid+=($pid)
#    sleep 1
#done

wait ${clone_pid[@]}

end_time=`date +%s`

time=$((end_time - start_time))
echo $time

