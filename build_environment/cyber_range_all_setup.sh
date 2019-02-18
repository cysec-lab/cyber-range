#!/bin/bash
# create cyber_range environment

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

WEB_TEMP_NUM=0    # initial web server template vm number. RANGE: 100~999
CLIENT_TEMP_NUM=0 # initial client pc template vm number. RANGE: 100~999
VYOS_TEMP_NUM=0   # initial vyos(software router os) template vm number. RANGE: 100~999

# Get JSON data
json_vm_data=`cat vm_info.json`
json_scenario_data=`cat scenario_info.json`
json_conf_data=`cat config_info.json`
group_num=`echo $json_scenario_data | jq '.group_num'`
student_per_group=`echo $json_scenario_data | jq '.student_per_group'`
git_home_get_command=`echo $json_conf_data | jq '.git_home_get_command' | sed 's/"//g'`
git_home=`$git_home_get_command`
tool_dir=$git_home`echo $json_conf_data | jq '.tool_dir' | sed 's/"//g'`
build_log_file=$git_home`echo $json_conf_data | jq '.build_log_file' | sed 's/"//g'`

# bridge number of connecting each group network(=Proxmox number)
VYOS_NETWORK_BRIDGE=$PROXMOX_NUM

read -p "scenario number(1 or 2): " scenario_num
if [ $scenario_num -eq 1 ] || [ $scenario_num -eq 2 ]; then
    scenario_data=`echo $json_vm_data | jq ".${clone_type}.scenario_nums[$((scenario_num - 1))]"`
    VYOS_TEMP_NUM=`echo $scenario_data | jq '.VYOS_TEMP_NUM'`
    CLIENT_TEMP_NUM=`echo $scenario_data | jq '.CLIENT_TEMP_NUM'`
    WEB_TEMP_NUM=`echo $scenario_data | jq '.WEB_TEMP_NUM'`
else
    echo 'invalid'
    exit 1
fi

# TODO: Decide to WEB_NUMS and CLIENT_NUMS setting rules
for g_num in `seq 1 $group_num`; do
    VYOS_NUMS+=("${g_num}11") # vyos number is *01
    WEB_NUMS+=("${g_num}12")  # web server number is *02
    for i in `seq 3 $((2 + $student_per_group))`; do
        CLIENT_NUMS+=("${g_num}1${i}") # client pc number are *03 ~ *09
    done
done

# time measurement start
start_time=`date +%s`

pc_type='vyos'
for num in ${VYOS_NUMS[@]}; do
    # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}"
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
    qm start $num &
done

pc_type='client'
for num in ${CLIENT_NUMS[@]}; do
    # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}"
    ip_address="192.168.${group_network_bridge}.${num:2:1}"
    snapshot_name="vm${num}_cloned_snapshot"
    _hostname="$pc_type$num"
    if [ $scenario_num -eq 2 ]; then
        # Windowsのクローンではテンプレート元を変更させる必要がある
        #mul_num=${num:0:1}
        #mul_num=$((mul_num - 1))
        #add_num=${num:2:1}
        #add_num=$((add_num - 3))
        #client_num=$((CLIENT_TEMP_NUM + student_per_group * mul_num + add_num))
        client_num=$CLIENT_TEMP_NUM
        $tool_dir/clone_vm.sh $clone_type $num $client_num $_hostname $TARGET_STRAGE $group_network_bridge # clone vm
    else
        $tool_dir/clone_vm.sh $clone_type $num $CLIENT_TEMP_NUM $_hostname $TARGET_STRAGE $group_network_bridge # clone vm
    fi
    if [ $scenario_num -eq 1 ]; then
        $tool_dir/centos_config_setup.sh $clone_type $num $ip_address $_hostname #change cloned vm's config file
    fi
    $tool_dir/create_snapshot.sh $num $snapshot_name # create snapshot
    qm start $num &
done

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
