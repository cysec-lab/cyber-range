#!/bin/bash
# create cyber_range environment
# - scenario 1 : Ransomeware
# - scenario 2 : Dos Attack

if [ $# -ne 1 ]; then
    echo "clone type need"
    echo "example:"
    echo "$0 zfs"
    exit 1
fi

clone_type=$1
if [ "$clone_type" = 'zfs' ]; then
    TARGET_STRAGE='local-zfs' # zfs clone target strage
elif [ "$clone_type" = 'full' ]; then
    TARGET_STRAGE='local'     # full clone target strage
else
    echo 'invalid data'
    echo 'clone type is zfs or full'
    exit 1
fi

VYOS_NUMS=()   # vyos(software router os) nums array
WEB_NUMS=()    # web server nums array
CLIENT_NUMS=() # client pc nums array

WEB_TEMP_NUM=0    # initial web server template vm number. RANGE: 100~999
CLIENT_TEMP_NUM=0 # initial client pc template vm number. RANGE: 100~999
VYOS_TEMP_NUM=0 # initial vyos(software router os) template vm number. RANGE: 100~999


# Get JSON data
json_vm_data=`cat json_files/vm_info.json`
json_scenario_data=`cat json_files/scenario_info.json`
json_conf_data=`cat json_files/config_info.json`
day=`echo $json_scenario_data | jq '.day'`
student_per_group=`echo $json_scenario_data | jq '.student_per_group'`
scenario_nums=(`echo $json_scenario_data | jq ".days[$((day - 1))].scenario_nums[].scenario_num"`)
SCENARIO_MAX_NUM=${#scenario_nums[@]}
git_home_get_command=`echo $json_conf_data | jq '.git_home_get_command' | sed 's/"//g'`
git_home=`$git_home_get_command`
tool_dir=$git_home`echo $json_conf_data | jq '.tool_dir' | sed 's/"//g'`
build_log_file=$git_home`echo $json_conf_data | jq '.build_log_file' | sed 's/"//g'`
GROUP_MAX_NUM=`echo $json_conf_data | jq '.GROUP_MAX_NUM'`

# bridge number of connectiong each group network(=Proxmox number)
VYOS_NETWORK_BRIDGE=$PROXMOX_NUM

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
    scenario_data=`echo $json_vm_data | jq ".${clone_type}.scenario_nums[$((scenario_num - 1))]"`
    VYOS_TEMP_NUM=`echo $scenario_data | jq '.VYOS_TEMP_NUM'`
    CLIENT_TEMP_NUM=`echo $scenario_data | jq '.CLIENT_TEMP_NUM'`
    WEB_TEMP_NUM=`echo $scenario_data | jq '.WEB_TEMP_NUM'`
fi

# time measurement start
start_time=`date +%s`

# delete before vms
for num in ${VYOS_NUMS[@]} ${WEB_NUMS[@]} ${CLIENT_NUMS[@]}; do
    $tool_dir/delete_vm.sh $num
done

pc_type='vyos'
for num in ${VYOS_NUMS[@]}; do
    # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}" # decide group netwrok bridge number
    snapshot_name="vm${num}_cloned_snapshot"
    _hostname="$pc_type$num"
    $tool_dir/clone_vm.sh $clone_type $num $VYOS_TEMP_NUM $_hostname $TARGET_STRAGE $VYOS_NETWORK_BRIDGE $group_network_bridge # clone vm
    $tool_dir/vyos_config_setup.sh $clone_type $num $VYOS_NETWORK_BRIDGE $group_network_bridge # change cloned vm's config files
    $tool_dir/create_snapshot.sh $num $snapshot_name # create snapshot
    qm start $num &
done

pc_type='web'
for num in ${WEB_NUMS[@]}; do
    # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}"
    ip_address="192.168.${group_network_bridge}.${num:2:1}"
    snapshot_name="vm${num}_cloned_snapshot"
    _hostname="$pc_type$num"
    $tool_dir/clone_vm.sh $clone_type $num $WEB_TEMP_NUM $_hostname $TARGET_STRAGE $group_network_bridge # clone vm
    $tool_dir/centos_config_setup.sh $clone_type $num $ip_address $_hostname # change cloned vm's config files
    $tool_dir/create_snapshot.sh $num $snapshot_name # create snapshot
    qm start $num
done

pc_type='client'
for num in ${CLIENT_NUMS[@]}; do
    # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}"
    ip_address="192.168.${group_network_bridge}.${num:2:1}"
    snapshot_name="vm${num}_cloned_snapshot"
    _hostname="$pc_type$num"
    if [ $scenario_num -eq 3 ]; then
        # Windowsのクローンではテンプレート元を変更させる必要がある
        mul_num=${num:0:1}
        mul_num=$((mul_num - 1))
        add_num=${num:2:1}
        add_num=$((add_num - 3))
        client_num=$((CLIENT_TEMP_NUM + student_per_group * mul_num + add_num))
        $tool_dir/clone_vm.sh $clone_type $num $client_num $_hostname $TARGET_STRAGE $group_network_bridge
    else
        $tool_dir/clone_vm.sh $clone_type $num $CLIENT_TEMP_NUM $_hostname $TARGET_STRAGE $group_network_bridge
    fi
    if [ $scenario_num -eq 1 ]; then
        $tool_dir/centos_config_setup.sh $clone_type $num $ip_address $_hostname
    fi
    $tool_dir/create_snapshot.sh $num $snapshot_name # create snapshot
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
 scenario          : $scenario_num
 group_num         : $group_num
 clone_type        : $clone_type
 router_template_vm: $VYOS_TEMP_NUM
 router_vms:       : ${VYOS_NUMS[@]}
 server_template_vm: $WEB_TEMP_NUM
 server_vms:       : ${WEB_NUMS[@]}
 client_template_vm: $CLIENT_TEMP_NUM
 client_vms:       : ${CLIENT_NUMS[@]}

EOL
