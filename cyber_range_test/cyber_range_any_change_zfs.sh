#!/bin/bash

VYOS_NUM=()
WEB_NUM=()
CLIENT_NUM=()
#VYOS_NUM=(511 521 531 541 551 561)
#WEB_NUM=(512 522 532 542 552 562)
#CLIENT_NUM=(513 514 515 516 523 524 525 526 533 534 535 536 543 544 545 546 553 554 555 556 563 564 565 566)

WEB_TEMP=0
CLIENT_TEMP=0
VYOS_TEMP=952

STUDENTS_PER_GROUP=4
GROUP_NUM=6
VG_NAME='VolGroup'
LOG_FILE="./setup.log"

read -p "group number(1 ~ $GROUP_NUM): " group_num
if [ $group_num -lt 1 ] || [ $GROUP_NUM -lt $group_num ]; then
    echo 'invalid'
    exit 1
else
    #VYOS_NUM+=("5${group_num}1")
    WEB_NUM+=("5${group_num}2")
    for i in `seq 3 $((2 + $STUDENTS_PER_GROUP))`; do
        CLIENT_NUM+=("5${group_num}${i}")
    done
fi

read -p "scenario number(1 or 2): " scenario_num
if [ $scenario_num -eq 1 ]; then
    WEB_TEMP=621
    CLIENT_TEMP=620
elif [ $scenario_num -eq 2 ]; then
    WEB_TEMP=621
    CLIENT_TEMP=922
else
    echo 'invalid'
    exit 1
fi


start_time=`date +%s`

# delete before vms
for num in ${VYOS_NUM[@]} ${WEB_NUM[@]} ${CLIENT_NUM[@]}; do 
    $WORK_DIR/delete_vm.sh $num
done

#pc_type='vyos'
#for num in ${VYOS_NUM[@]}; do
#    $WORK_DIR/clone_vm.sh $num $VYOS_TEMP $pc_type
#    $WORK_DIR/vyos_config_setup.sh $num
#    qm start $num &
#done

pc_type='web'
for num in ${WEB_NUM[@]}; do
    ip_address="192.168.${num:0:2}.${num:2:1}"
    $WORK_DIR/zfs_clone_vm.sh $num $WEB_TEMP $pc_type
    $WORK_DIR/zfs_centos_config_setup.sh $num $ip_address $pc_type $VG_NAME
    qm start $num
done

pc_type='client'
for num in ${CLIENT_NUM[@]}; do
    ip_address="192.168.${num:0:2}.${num:2:1}"
    $WORK_DIR/zfs_clone_vm.sh $num $CLIENT_TEMP $pc_type
    if [ $scenario_num -eq 1 ]; then
        $WORK_DIR/zfs_centos_config_setup.sh $num $ip_address $pc_type $VG_NAME
    fi
    qm start $num
done

end_time=`date +%s`

time=$((end_time - start_time))
echo $time

# ログ出力
echo "[`date "+%Y/%m/%d %H:%M:%S"`] $0 $*" >> $LOG_FILE
echo " time              : $time [s]" >> $LOG_FILE
echo " scenario          : $scenario_num" >> $LOG_FILE
echo " server_template_vm: $WEB_TEMP" >> $LOG_FILE
echo " server_vms:       : ${WEB_NUM[@]}" >> $LOG_FILE
echo " client_template_vm: $CLIENT_TEMP" >> $LOG_FILE
echo " client_vms:       : ${CLIENT_NUM[@]}" >> $LOG_FILE
echo >> $LOG_FILE
