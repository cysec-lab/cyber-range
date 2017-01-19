#!/bin/bash

start_time=`date +%s`

CLIENT_NUM=(611 612 613 621 622 623 631 632 633 634 641 642 643)
WEB_NUM=(614 624 634 644)
clone_pid=()

PC_TYPE='client'
for num in ${CLIENT_NUM[@]}; do
    ./clone_vm.sh $PC_TYPE 599 $num 
    ./disk_mount.sh $num 192.168.1${num:1:1}0.${num:1:2} $PC_TYPE client711
    qm start $num &
    #pid=$!
    #clone_pid+=($pid)
done

PC_TYPE='web'
for num in ${WEB_NUM[@]}; do
    ./clone_vm.sh $PC_TYPE 600 $num
    ./disk_mount.sh $num 192.168.1${num:1:1} $PC_TYPE web713
    qm start $num &
    #pid=$!
    #clone_pid+=($pid)
    #sleep 1
done

#wait ${clone_pid[@]}

end_time=`date +%s`

time=$((end_time - start_time))
echo $time

