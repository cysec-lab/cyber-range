#!/bin/bash

start_time=`date +%s`

./auto_setup_test_delete.sh

CLIENT_NUM=(311 312 313 321 322 323 331 332 333 341 342 343)
WEB_NUM=(314 324 334 344)
VYOS_NUM=(221 222 223 224)

#CLIENT_NUM=()
#WEB_NUM=(314)
#VYOS_NUM=()

for num in ${WEB_NUM[@]}; do
	ADDRESS="192.168.1${num:1:1}0.${num:1:2}"
	VG_NAME='vg_web713'
	./clone_vm.sh 'web' 716 $num
	./disk_mount_ignore_uuid_change.sh $num $ADDRESS 'web' $VG_NAME
	#./uuid_setup.sh $num $ADDRESS 'web' $VG_NAME
	#./centos_config_setup.sh $num $ADDRESS 'web' $VG_NAME &
	# ./disk_umount.sh $num $ADDRESS 'web' $VG_NAME  # in centos_config_setup.sh
	qm start $num # in centos_config_setup.sh
done

for num in ${CLIENT_NUM[@]}; do
	ADDRESS="192.168.1${num:1:1}0.${num:1:2}"
	VG_NAME='VolGroup'
	./clone_vm.sh 'client' 715 $num
	./disk_mount_ignore_uuid_change.sh $num $ADDRESS 'client' $VG_NAME
	#./uuid_setup.sh $num $ADDRESS 'client' $VG_NAME
	#./centos_config_setup.sh $num $ADDRESS 'client' $VG_NAME &
	# ./disk_umont.sh $num $ADDRESS 'client' $VG_NAME # in centos_config_setup.sh
	 qm start $num &
done

for num in ${VYOS_NUM[@]}; do
	./clone_vm.sh 'vyos' 200 $num
	./disk_mount_vyos.sh $num 192.168.1${num:2:1}0.1  vyos-template
	qm start $num &
done

end_time=`date +%s`

time=$((end_time - start_time))
echo $time
