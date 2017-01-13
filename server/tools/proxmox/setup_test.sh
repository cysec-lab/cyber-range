#!/bin/bash

start_time=`date +%s`

CLIENT_NUM=(311 312 313 321 322 323 331 332 333 341 342 343)
WEB_NUM=(314 324 334 344)
VYOS_NUM=(221 222 223 224)
clone_pid=()

for num in ${WEB_NUM[@]}; do
	./clone_vm.sh 'web' 716 $num
	./disk_mount.sh $num 192.168.1${num:1:1}0.${num:1:2} 'web' web713	
	qm start $num & 
	#pid=$!
	#clone_pid+=($pid)
	#sleep 1
done

for num in ${CLIENT_NUM[@]}; do
	./clone_vm.sh 'client' 711 $num
	./disk_mount.sh $num 192.168.1${num:1:1}0.${num:1:2} 'client' client711
	qm start $num &
	#pid=$!
	#clone_pid+=($pid)
	#sleep 1
done

for num in ${VYOS_NUM[@]}; do
	./clone_vm.sh 'vyos' 200 $num
	./disk_mount_vyos.sh $num 192.168.1${num:2:1}0.1  vyos-template
	qm start $num &
	#pid=$!
	#clone_pid+=($pid)
	#sleep 1
done

wait ${clone_pid[@]}

end_time=`date +%s`

time=$((end_time - start_time))
echo $time
