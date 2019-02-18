#!/bin/bash
# delete cyber_range environment
# - select delete group number range
#   if select 5 delete 1~5 group

# Get JSON data
json_vm_data=`cat vm_info.json`
json_scenario_data=`cat scenario_info.json`
json_conf_data=`cat config_info.json`
day=`echo $json_scenario_data | jq '.day'`
group_num=`echo $json_scenario_data | jq '.group_num'`
student_per_group=`echo $json_scenario_data | jq '.student_per_group'`
scenario_nums=`echo $json_scenario_data | jq ".days[$((day - 1))].scenario_nums[].scenario_num"`
git_home_get_command=`echo $json_conf_data | jq '.git_home_get_command' | sed 's/"//g'`
git_home=`$git_home_get_command`
tool_dir=$git_home`echo $json_conf_data | jq '.tool_dir' | sed 's/"//g'`
build_log_file=$git_home`echo $json_conf_data | jq '.build_log_file' | sed 's/"//g'`

# TODO: Decide to WEB_NUMS and CLIENT_NUMS setting rules
loop_num=1 # 1から始まる通し番号
for _ in $scenario_nums; do
    for g_num in `seq 1 $group_num`; do
        VYOS_NUMS+=("${g_num}${loop_num}1") # vyos number is **1
        WEB_NUMS+=("${g_num}${loop_num}2")  # web server number is **2
        for i in `seq 3 $((2 + $student_per_group))`; do
            CLIENT_NUMS+=("${g_num}${loop_num}${i}") # client pc number are **3 ~ **9
        done
    done
    let "loop_num=loop_num+1" # increment
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
echo "[`date "+%Y/%m/%d %H:%M:%S"`] $0 $*" >> $build_log_file
echo " time              : $time [s]" >> $build_log_file
echo " group_num         : $group_num" >> $build_log_file
echo " router_vms:       : ${VYOS_NUMS[@]}" >> $build_log_file
echo " server_vms:       : ${WEB_NUMS[@]}" >> $build_log_file
echo " client_vms:       : ${CLIENT_NUMS[@]}" >> $build_log_file
echo >> $build_log_file
