#!/bin/bash
# create cyber_range environment
# TODO: zfsかfullかでrollbackの方式を変える

VYOS_NUMS=()   # vyos(software router os) nums array
WEB_NUMS=()    # web server nums array
CLIENT_NUMS=() # client pc nums array

GROUP_MAX_NUM=7        # group upper limit per Proxmox server
SCENARIO_MAX_NUM=6

# Get JSON data
json_scenario_data=`cat json_files/scenario_info.json`
json_conf_data=`cat json_files/config_info.json`
student_per_group=`echo $json_scenario_data | jq '.student_per_group'`
vm_config_dir=`echo $json_conf_data | jq '.vm_config_dir'`
git_home_get_command=`echo $json_conf_data | jq '.git_home_get_command' | sed 's/"//g'`
git_home=`$git_home_get_command`
tool_dir=$git_home`echo $json_conf_data | jq '.tool_dir' | sed 's/"//g'`
build_log_file=$git_home`echo $json_conf_data | jq '.build_log_file' | sed 's/"//g'`

read -p "group number(1 ~ $GROUP_MAX_NUM): " group_num
if [ $group_num -lt 1 ] || [ $GROUP_MAX_NUM -lt $group_num ]; then
    echo 'invalid'
    exit 1
fi

read -p "scenario number(1 ~ $SCENARIO_MAX_NUM): " scenario_num
if [ $scenario_num -lt 1 ] || [ $SCENARIO_MAX_NUM -lt $scenario_num ]; then
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

# roll_back vms
for num in ${VYOS_NUMS[@]} ${WEB_NUMS[@]} ${CLIENT_NUMS[@]}; do
    snapshot_name="vm${num}_cloned_snapshot"
    qm stop $num
    $tool_dir/rollback_snapshot.sh $num $snapshot_name # rollback snapshot
    qm start $num
done

# time measurement end
end_time=`date +%s`

time=$((end_time - start_time))
echo $time

# output logs
cat << EOL >> $build_log_file
[`date "+%Y/%m/%d %H:%M:%S"`] $0 $*
 time              : $time [s]
 group_num         : $group_num
 scenario_num:     : $scenario_num
 router_vms:       : ${VYOS_NUMS[@]}
 server_vms:       : ${WEB_NUMS[@]}
 client_vms:       : ${CLIENT_NUMS[@]}

EOL
