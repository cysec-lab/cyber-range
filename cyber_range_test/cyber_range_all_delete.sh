#!/bin/bash


PROXMOX_MAX_NUM=9
STUDENTS_PER_GROUP=4
GROUP_MAX_NUM=8

# TODO: Now only use server number 1
PROXMOX_NUM=1
#read -p "proxmox number(0 ~ $PROXMOX_MAX_NUM): " proxmox_num
#if [ $proxmox -lt 0 ] || [ $PROXMOX_MAX_NUM -lt $proxmox_num ]; then
#    echo 'invalid'
#    exit 1
#else
#    PROXMOX_NUM=$proxmox_num
#fi

# TODO: Decide to WEB_NUM and CLIENT_NUM setting rules
#       Now, determinate same composition
read -p "group number(1 ~ $GROUP_MAX_NUM): " group_num
if [ $group_num -lt 1 ] || [ $GROUP_MAX_NUM -lt $group_num ]; then
    echo 'invalid'
    exit 1
else
    for g_num in `seq 1 $group_num`; do
        VYOS_NUM+=("${g_num}01")
        WEB_NUM+=("${g_num}02")
        for i in `seq 3 $((2 + $STUDENTS_PER_GROUP))`; do
            CLIENT_NUM+=("${g_num}0${i}")
        done
    done
fi

LOG_FILE="./setup.log"

start_time=`date +%s`

# delete before vms
for num in ${VYOS_NUM[@]} ${WEB_NUM[@]} ${CLIENT_NUM[@]}; do 
    $WORK_DIR/delete_vm.sh $num
done

end_time=`date +%s`

time=$((end_time - start_time))
echo $time

# output logs
echo "[`date "+%Y/%m/%d %H:%M:%S"`] $0 $*" >> $LOG_FILE
echo " time              : $time [s]" >> $LOG_FILE
echo " group_num         : $group_num" >> $LOG_FILE
echo " server_vms:       : ${WEB_NUM[@]}" >> $LOG_FILE
echo " client_vms:       : ${CLIENT_NUM[@]}" >> $LOG_FILE
echo >> $LOG_FILE
