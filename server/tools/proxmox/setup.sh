#!/bin/bash
#TODO cloneの自動化は出来たが、clone後のPCとは接続できない
#     ipアドレスが割り振られていない

start_time=`date +%s`

PC_TYPE='web'
VM_NUM=(600 601 602 603 604 605)
clone_pid=()

for num in ${VM_NUM[@]}; do
    ./clone_vm.sh $PC_TYPE 414 $num &
    pid=$!
    clone_pid+=($pid)
done

wait ${clone_pid[@]}

end_time=`date +%s`

time=$((end_time - start_time))
echo $time

