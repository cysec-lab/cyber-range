#!/bin/bash

#start_time=`date +%s`
#
#for ((i=6;i<8;i++)); do
#	num=$((800+i))
#	./clone_vm.sh $num 954 WindowsTemplate local-tvm 5
#	./send_snapshot.sh $num tvmpool rpool
#done
#
#end_time=`date +%s`
#
#time=$((end_time - start_time))
#echo $time

#MACADDRESS=`dd if=/dev/urandom bs=1024 count=1 2>/dev/null|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\)\(..\).*$/\1:\2:\3:\4:\5:\6/'`
#echo $MACADDRESS

BRIDGE_NUMS=(5 151)
CLONE_CONFIG_PATH='./900.conf'

for ((i=0;i<${#BRIDGE_NUMS[@]};i++)); do
	mac_address=`dd if=/dev/urandom bs=1024 count=1 2>/dev/null|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\)\(..\).*$/\1:\2:\3:\4:\5:\6/'`
	new_rule="net${i}: e1000=${mac_address},bridge=vmbr${BRIDGE_NUMS[i]}"
    	# clone時にconfファイルにparentとして以前のデータが残ることがあるが前のデータを残すために最初にマッチした行のみ変更を加える
	sed -i -e "0,/^net${i}/s/^net${i}.*/$new_rule/g" $CLONE_CONFIG_PATH
	#echo $new_rule
done
