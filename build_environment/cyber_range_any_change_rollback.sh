#!/bin/bash
# create cyber_range environment
# TODO: zfsかfullかでrollbackの方式を変える
# TODO: スクリプト名の修正

tool_dir=/root/github/cyber_range/server/tools/proxmox

VYOS_NUMS=()   # vyos(software router os) nums array
WEB_NUMS=()    # web server nums array
CLIENT_NUMS=() # client pc nums array

GROUP_MAX_NUM=7        # group upper limit per Proxmox server
LOG_FILE="./setup.log" # log file name

# Get JSON data
json_scenario_data=`cat scenario_info.json`
student_per_group=`echo $json_scenario_data | jq '.student_per_group'`

read -p "group number(1 ~ $GROUP_MAX_NUM): " group_num
if [ $group_num -lt 1 ] || [ $GROUP_MAX_NUM -lt $group_num ]; then
    echo 'invalid'
    exit 1
else
    # TODO: Decide to WEB_NUMS and CLIENT_NUMS setting rules
    VYOS_NUMS+=("${group_num}11") # vyos number is *11
    WEB_NUMS+=("${group_num}12")  # web server number is *12
    for i in `seq 3 $((2 + $student_per_group))`; do
        CLIENT_NUMS+=("${group_num}1${i}") # client pc number are *13 ~ *19
    done
fi

# time measurement start
start_time=`date +%s`

# roll_back vms
for num in ${VYOS_NUMS[@]} ${WEB_NUMS[@]} ${CLIENT_NUMS[@]}; do
    snapshot_name="vm${num}_cloned_snapshot"
    qm stop $num &
    $tool_dir/rollback_snapshot.vm $num $snapshot_name # rollback snapshot
    qm start $num
done

# time measurement end
end_time=`date +%s`

time=$((end_time - start_time))
echo $time

# output logs
cat << EOL >> $LOG_FILE
[`date "+%Y/%m/%d %H:%M:%S"`] $0 $*
 time              : $time [s]
 group_num         : $group_num
 router_vms:       : ${VYOS_NUMS[@]}
 server_vms:       : ${WEB_NUMS[@]}
 client_vms:       : ${CLIENT_NUMS[@]}

EOL
