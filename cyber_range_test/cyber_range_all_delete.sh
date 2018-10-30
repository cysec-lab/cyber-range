#!/bin/bash
# delete cyber_range environment
# - select delete group number range
#   if select 5 delete 1~5 group

tool_dir=/root/github/cyber_range/server/tools/proxmox # proxmox tool dir

SCENARIO_NUM=4         # create scinario num.
STUDENTS_PER_GROUP=4 # number of students in exercise per groups
GROUP_MAX_NUM=8      # group upper limit per Proxmox server

LOG_FILE="./setup.log"

# Get JSON data
json_vm_data=`cat vm_info.json`
json_scenario_data=`cat scenario_info.json`
day=`echo $json_scenario_data | jq '.day'`
group_num=`echo $json_scenario_data | jq '.group_num'`
student_per_group=`echo $json_scenario_data | jq '.student_per_group'`
scenario_nums=`echo $json_scenario_data | jq ".days[$((day - 1))].scenario_nums[].scenario_num"`

# TODO: Decide to WEB_NUMS and CLIENT_NUMS setting rules
serial_num=0 # 0から始まる通し番号
for _ in $scenario_nums; do
    for g_num in `seq 1 $group_num`; do
        VYOS_NUMS+=("${g_num}${serial_num}1") # vyos number is *01
        WEB_NUMS+=("${g_num}${serial_num}2")  # web server number is *02
        for i in `seq 3 $((2 + $student_per_group))`; do
            CLIENT_NUMS+=("${g_num}${serial_num}${i}") # client pc number are *03 ~ *09
        done
    done
    let "serial_num=serial_num+1" # increment
done

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
