#!/bin/bash

start_time=`date +%s`

#CLIENT_NUM=(611 612 613 621 622 623 631 632 633 634 641 642 643)
#WEB_NUM=(614 624 634 644)
#ROOTER_NUM=(615 625 635 645)
clone_pid=()

#for num in ${CLIENT_NUM[@]}; do
#    ./zfs_clone_vm.sh 'windows' 498 $num &
#    pid=$!
#    clone_pid+=($pid)
#done
#
#for num in ${WEB_NUM[@]}; do
#    ./zfs_clone_vm.sh 'windows' 498 $num &
#    pid=$!
#    clone_pid+=($pid)
#    sleep 1
#done
#
#for num in ${ROOTER_NUM[@]}; do
#    ./zfs_clone_vm.sh 'windows' 498 $num &
#    pid=$!
#    clone_pid+=($pid)
#    sleep 1
#done

for num in `seq 800 899`; do
    echo $num
    ./zfs_clone_vm.sh 'windows' 411 $num &
    pid=$!
    clone_pid+=($pid)
done

wait ${clone_pid[@]}

end_time=`date +%s`

time=$((end_time - start_time))
echo $time

