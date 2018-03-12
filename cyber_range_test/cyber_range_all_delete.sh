#!/bin/bash

start_time=`date +%s`

STUDENTS_PER_GROUP=4
GROUP_NUM=6

read -p "group number(1 ~ $GROUP_NUM): " group_num
if [ $group_num -lt 1 ] || [ $GROUP_NUM -lt $group_num ]; then
    echo 'invalid'
    exit 1
else
    for g_num in `seq 1 $group_num`; do
        #VYOS_NUM+=("5${group_num}1")
        WEB_NUM+=("5${g_num}2")
        for i in `seq 3 $((2 + $STUDENTS_PER_GROUP))`; do
            CLIENT_NUM+=("5${g_num}${i}")
        done
    done
fi

LOG_FILE="./setup.log"
#VYOS_NUM=(511 521 531 541 551 561)
#WEB_NUM=(512 522 532 542 552 562)
#CLIENT_NUM=(513 514 515 516 523 524 525 526 533 534 535 536 543 544 545 546 553 554 555 556 563 564 565 566)

# delete before vms
for num in ${VYOS_NUM[@]} ${WEB_NUM[@]} ${CLIENT_NUM[@]}; do 
    $WORK_DIR/delete_vm.sh $num
done

end_time=`date +%s`

time=$((end_time - start_time))
echo $time

# ログ出力
echo "[`date "+%Y/%m/%d %H:%M:%S"`] $0 $*" >> $LOG_FILE
echo " time              : $time [s]" >> $LOG_FILE
echo " group_num         : $group_num" >> $LOG_FILE
echo " server_vms:       : ${WEB_NUM[@]}" >> $LOG_FILE
echo " client_vms:       : ${CLIENT_NUM[@]}" >> $LOG_FILE
echo >> $LOG_FILE
