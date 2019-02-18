#!/bin/bash
# create cyber_range environment
# - scenario 1 : Ransomeware
# - scenario 2 : Dos Attack

tool_dir=/root/github/cyber_range/server/tools/proxmox

VYOS_NUMS=()   # vyos(software router os) nums array
WEB_NUMS=()    # web server nums array
CLIENT_NUMS=() # client pc nums array

SCENARIO_MAX_NUM=4     # create scinario num.
GROUP_MAX_NUM=7        # group upper limit per Proxmox server
LOG_FILE="./setup.log" # log file name

# Get JSON data
json_scenario_data=`cat json_files/scenario_info.json`
student_per_group=`echo $json_scenario_data | jq '.student_per_group'`

read -p "group number(1 ~ $GROUP_MAX_NUM): " group_num
if [ $group_num -lt 1 ] || [ $GROUP_MAX_NUM -lt $group_num ]; then
    echo 'invalid'
    exit 1
fi

read -p "next scenario number(1 ~ $SCENARIO_MAX_NUM): " scenario_num
if [ $scenario_num -le 1 ] || [ $SCENARIO_MAX_NUM -lt $scenario_num ]; then
    echo 'invalid'
    exit 1
else
    # TODO: Decide to WEB_NUMS and CLIENT_NUMS setting rules
    VYOS_NUMS+=("${group_num}${scenario_num}1") # vyos number is *01
    WEB_NUMS+=("${group_num}${scenario_num}2")  # web server number is *02
    for i in `seq 3 $((2 + $student_per_group))`; do
        CLIENT_NUMS+=("${group_num}${scenario_num}${i}") # client pc number are *03 ~ *09
    done
fi

# time measurement start
start_time=`date +%s`

# stop vms
for num in ${VYOS_NUMS[@]} ${WEB_NUMS[@]} ${CLIENT_NUMS[@]}; do
    stop_num=$((num - 10))
    qm stop $stop_num
    qm start $num &
done

# time measurement end
end_time=`date +%s`

time=$((end_time - start_time))
echo $time

# output logs
cat << EOL >> $LOG_FILE
[`date "+%Y/%m/%d %H:%M:%S"`] $0 $*
 time              : $time [s]
 next scenario     : $scenario_num
 group_num         : $group_num
 router_vms:       : ${VYOS_NUMS[@]}
 server_vms:       : ${WEB_NUMS[@]}
 client_vms:       : ${CLIENT_NUMS[@]}

EOL
