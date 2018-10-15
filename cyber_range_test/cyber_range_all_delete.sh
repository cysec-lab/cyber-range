#!/bin/bash
# delete cyber_range environment
# - select delete group number range
#   if select 5 delete 1~5 group

tool_dir=/root/github/cyber_range/server/tools/proxmox # proxmox tool dir

SCENARIO_NUM=4         # create scinario num.
STUDENTS_PER_GROUP=4 # number of students in exercise per groups
GROUP_MAX_NUM=8      # group upper limit per Proxmox server

# TODO: Decide to WEB_NUMS and CLIENT_NUMS setting rules
#       Now, determinate same composition
read -p "group number(1 ~ $GROUP_MAX_NUM): " group_num
if [ $group_num -lt 1 ] || [ $GROUP_MAX_NUM -lt $group_num ]; then
    echo 'invalid'
    exit 1
else
    for scenario_num in `seq $SCENARIO_NUM`; do
        for g_num in `seq 1 $group_num`; do
            VYOS_NUMS+=("${g_num}${scenario_num}1") # vyos number is *01
            WEB_NUMS+=("${g_num}${scenario_num}2")  # web server number is *02
            for i in `seq 3 $((2 + $STUDENTS_PER_GROUP))`; do
                CLIENT_NUMS+=("${g_num}${scenario_num}${i}") # client pc number are *03 ~ *09
            done
        done
    done
fi

LOG_FILE="./setup.log"

start_time=`date +%s`

# delete before vms
for num in ${VYOS_NUMS[@]} ${WEB_NUMS[@]} ${CLIENT_NUMS[@]}; do
    $tool_dir/delete_vm.sh $num # delete vm script
done

end_time=`date +%s`

time=$((end_time - start_time))
echo $time

# output logs
echo "[`date "+%Y/%m/%d %H:%M:%S"`] $0 $*" >> $LOG_FILE
echo " time              : $time [s]" >> $LOG_FILE
echo " group_num         : $group_num" >> $LOG_FILE
echo " router_vms:       : ${VYOS_NUMS[@]}" >> $LOG_FILE
echo " server_vms:       : ${WEB_NUMS[@]}" >> $LOG_FILE
echo " client_vms:       : ${CLIENT_NUMS[@]}" >> $LOG_FILE
echo >> $LOG_FILE
