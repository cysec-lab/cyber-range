#!/bin/bash
# create cyber_range environment
# - scenario 1 : Ransomeware
# - scenario 2 : Dos Attack

TARGET_STRAGE='local'  # full clone target strage

# Get JSON data
json_vm_data=`cat vm_info.json`
json_scenario_data=`cat scenario_info.json`
json_conf_data=`cat config_info.json`
day=`echo $json_scenario_data | jq '.day'`
group_num=`echo $json_scenario_data | jq '.group_num'`
student_per_group=`echo $json_scenario_data | jq '.student_per_group'`
scenario_nums=`echo $json_scenario_data | jq ".days[$((day - 1))].scenario_nums[].scenario_num"`
clone_types=(`echo $json_scenario_data | jq ".days[$((day - 1))].scenario_nums[].clone_type" | sed 's/"//g'`)
git_home_get_command=`echo $json_conf_data | jq '.git_home_get_command' | sed 's/"//g'`
git_home=`$git_home_get_command`
tool_dir=$git_home`echo $json_conf_data | jq '.tool_dir' | sed 's/"//g'`
build_log_file=$git_home`echo $json_conf_data | jq '.build_log_file' | sed 's/"//g'`

# bridge number of connecting each group network(=Proxmox number)
VYOS_NETWORK_BRIDGE=$PROXMOX_NUM

# TODO: Consider to WEB_NUMS and CLIENT_NUMS setting rules
loop_num=1 # 1から始まる通し番号
for scenario_num in $scenario_nums; do
    # クローン用のVM番号配列を生成
    for g_num in `seq 1 $group_num`; do
        VYOS_NUMS+=("${g_num}${loop_num}1") # vyos number is **1
        WEB_NUMS+=("${g_num}${loop_num}2")  # web server number is **2
        for i in `seq 3 $((2 + $student_per_group))`; do
            CLIENT_NUMS+=("${g_num}${loop_num}${i}") # client pc number are **3 ~ **9
        done
    done

    # テンプレートVM用の配列生成
    clone_type=`echo ${clone_types[$((loop_num - 1))]}`
    scenario_data=`echo $json_vm_data | jq ".${clone_type}.scenario_nums[$((scenario_num - 1))]"`
    VYOS_TEMP_NUM=`echo $scenario_data | jq '.VYOS_TEMP_NUM'`
    CLIENT_TEMP_NUM=`echo $scenario_data | jq '.CLIENT_TEMP_NUM'`
    WEB_TEMP_NUM=`echo $scenario_data | jq '.WEB_TEMP_NUM'`
    VYOS_TEMP_NUMS+=($VYOS_TEMP_NUM)
    CLIENT_TEMP_NUMS+=($CLIENT_TEMP_NUM)
    WEB_TEMP_NUMS+=($WEB_TEMP_NUM)

    let "loop_num=loop_num+1" # increment
done

start_time=`date +%s`

loop_num=0 # 0から始まる通し番号
for scenario_num in $scenario_nums; do
    clone_type=`echo ${clone_types[$loop_num]}`
    vyos_nums=${VYOS_NUMS[@]:$((loop_num * group_num)):$group_num}
    web_nums=${WEB_NUMS[@]:$((loop_num * group_num)):$group_num}
    client_nums=${CLIENT_NUMS[@]:$((loop_num * group_num * student_per_group)):$((group_num * student_per_group))}

    pc_type='vyos'
    for num in ${vyos_nums[@]}; do
        # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
        group_network_bridge="1${PROXMOX_NUM}${num:0:1}" # decide group netwrok bridge number
        snapshot_name="vm${num}_cloned_snapshot"
        _hostname="$pc_type$num"
        if [ "$clone_type" = 'zfs' ]; then
            $tool_dir/zfs_clone_vm.sh $num ${VYOS_TEMP_NUMS[$loop_num]} $_hostname $VYOS_NETWORK_BRIDGE $group_network_bridge # clone vm by zfs clone
            $tool_dir/zfs_vyos_config_setup.sh $num $VYOS_NETWORK_BRIDGE $group_network_bridge            # change cloned vm's config files
            $tool_dir/create_snapshot_zfs.sh $num $snapshot_name # create snapshot
        else
            $tool_dir/clone_vm.sh $num ${VYOS_TEMP_NUMS[$loop_num]} $_hostname $TARGET_STRAGE $VYOS_NETWORK_BRIDGE $group_network_bridge
            $tool_dir/vyos_config_setup.sh $num $VYOS_NETWORK_BRIDGE $group_network_bridge
            $tool_dir/create_snapshot.sh $num $snapshot_name # create snapshot
        fi
    
        # first scenario's vm starts
        if [ ${num:1:1} -eq '1' ]; then
            qm start $num &
        fi
    done
    
    pc_type='web'
    for num in ${web_nums[@]}; do
        # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
        group_network_bridge="1${PROXMOX_NUM}${num:0:1}" # decide group network bridge number
        ip_address="192.168.${group_network_bridge}.${num:2:1}" # new vm's ip address
        snapshot_name="vm${num}_cloned_snapshot"
        _hostname="$pc_type$num"
        if [ "$clone_type" = 'zfs' ]; then
            $tool_dir/zfs_clone_vm.sh $num ${WEB_TEMP_NUMS[$loop_num]} $_hostname $group_network_bridge # clone vm by zfs clone
            $tool_dir/zfs_centos_config_setup.sh $num $ip_address $_hostname # change cloned vm's config files
            $tool_dir/create_snapshot_zfs.sh $num $snapshot_name # create snapshot
        else
            $tool_dir/clone_vm.sh $num ${WEB_TEMP_NUMS[$loop_num]} $_hostname $TARGET_STRAGE $group_network_bridge
            $tool_dir/centos_config_setup.sh $num $ip_address $_hostname # change cloned vm's config files
            $tool_dir/create_snapshot.sh $num $snapshot_name # create snapshot
        fi

        # first scenario's vm starts
        if [ ${num:1:1} -eq '1' ]; then
            qm start $num &
        fi
    done
    
    pc_type='client'
    for num in ${client_nums[@]}; do
        # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
        group_network_bridge="1${PROXMOX_NUM}${num:0:1}" # decide group network bridge number
        ip_address="192.168.${group_network_bridge}.${num:2:1}" # new vm's ip address
        snapshot_name="vm${num}_cloned_snapshot"
        _hostname="$pc_type$num"
        if [ "$clone_type" = 'zfs' ]; then
            if [ $scenario_num -eq 3 ]; then
                mul_num=${num:0:1}
                mul_num=$((mul_num - 1))
                add_num=${num:2:1}
                add_num=$((add_num - 3))
                client_num=$((CLIENT_TEMP_NUMS[$loop_num] + student_per_group * mul_num + add_num))
            	$tool_dir/zfs_clone_vm.sh $num $client_num $_hostname $group_network_bridge
            else
            	$tool_dir/zfs_clone_vm.sh $num ${CLIENT_TEMP_NUMS[$loop_num]} $_hostname $group_network_bridge
            fi
            if [ $scenario_num -eq 1 ]; then
                $tool_dir/zfs_centos_config_setup.sh $num $ip_address $_hostname #change cloned vm's config file
            fi
            $tool_dir/create_snapshot_zfs.sh $num $snapshot_name # create snapshot
        else
            if [ $scenario_num -eq 2 ]; then
                #mul_num=${num:0:1}
                #mul_num=$((mul_num - 1))
                #add_num=${num:2:1}
                #add_num=$((add_num - 3))
                #client_num=$((CLIENT_TEMP_NUM + student_per_group * mul_num + add_num))
                client_num=$CLIENT_TEMP_NUM
            	$tool_dir/clone_vm.sh $num $client_num $_hostname $TARGET_STRAGE $group_network_bridge
            else
            	$tool_dir/clone_vm.sh $num ${CLIENT_TEMP_NUMS[$loop_num]} $_hostname $TARGET_STRAGE $group_network_bridge
            fi
            if [ $scenario_num -eq 1 ]; then
                $tool_dir/centos_config_setup.sh $num $ip_address $_hostname # change cloned vm's config files
            fi
            $tool_dir/create_snapshot.sh $num $snapshot_name # create snapshot
        fi

        # first scenario's vm starts
        if [ ${num:1:1} -eq '1' ]; then
            qm start $num &
        fi
    done
    let "loop_num=loop_num+1"
done

end_time=`date +%s`

time=$((end_time - start_time))
echo $time

# output logs
cat << EOL >> $build_log_file
[`date "+%Y/%m/%d %H:%M:%S"`] $0 $*
 time               : $time [s]
 group_num          : $group_num
 scenario_nums      : ${scenario_num[@]}
 clone_types        : ${clone_types[@]}
 router_template_vms: ${VYOS_TEMP_NUMS[@]}
 router_vms:        : ${VYOS_NUMS[@]}
 server_template_vms: ${WEB_TEMP_NUMS[@]}
 server_vms:        : ${WEB_NUMS[@]}
 client_template_vms: ${CLIENT_TEMP_NUMS[@]}
 client_vms:        : ${CLIENT_NUMS[@]}

EOL
