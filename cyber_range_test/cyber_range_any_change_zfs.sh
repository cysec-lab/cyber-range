#!/bin/bash
# create cyber_range environment
# - clone type : zfs
# - scenario 1 : Ransomeware
# - scenario 2 : Dos Attack

tool_dir=/root/github/cyber_range/server/tools/proxmox

VYOS_NUMS=()   # vyos(software router os) nums array
WEB_NUMS=()    # web server nums array
CLIENT_NUMS=() # client pc nums array

WEB_TEMP_NUM=0    # initial web server template vm number. RANGE: 100~999
CLIENT_TEMP_NUM=0 # initial client pc template vm number. RANGE: 100~999
VYOS_TEMP_NUM=0 # initial vyos(software router os) template vm number. RANGE: 100~999

GROUP_MAX_NUM=7        # group upper limit per Proxmox server
CLONE_TYPE='zfs'       # clone type
LOG_FILE="./setup.log" # log file name

# Get JSON data
json_vm_data=`cat vm_info.json`
json_scenario_data=`cat scenario_info.json`
student_per_group=`echo $json_scenario_data | jq '.student_per_group'`

# bridge number of connectiong each group network(=Proxmox number)
VYOS_NETWORK_BRIDGE=$PROXMOX_NUM

read -p "group number(1 ~ $GROUP_MAX_NUM): " group_num
if [ $group_num -lt 1 ] || [ $GROUP_MAX_NUM -lt $group_num ]; then
    echo 'invalid'
    exit 1
else
    # TODO: Decide to WEB_NUMS and CLIENT_NUMS setting rules
    VYOS_NUMS+=("${group_num}11") # vyos number is *01
    WEB_NUMS+=("${group_num}12")  # web server number is *02
    for i in `seq 3 $((2 + $student_per_group))`; do
        CLIENT_NUMS+=("${group_num}1${i}") # client pc number are *03 ~ *09
    done
fi

read -p "scenario number(1 or 2): " scenario_num
if [ $scenario_num -eq 1 ] || [ $scenario_num -eq 2 ]; then
    scenario_data=`echo $json_vm_data | jq ".${CLONE_TYPE}.scenario_nums[$((scenario_num - 1))]"`
    VYOS_TEMP_NUM=`echo $scenario_data | jq '.VYOS_TEMP_NUM'`
    CLIENT_TEMP_NUM=`echo $scenario_data | jq '.CLIENT_TEMP_NUM'`
    WEB_TEMP_NUM=`echo $scenario_data | jq '.WEB_TEMP_NUM'`
else
    echo 'invalid'
    exit 1
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
    $tool_dir/zfs_clone_vm.sh $num $VYOS_TEMP_NUM $_hostname $VYOS_NETWORK_BRIDGE $group_network_bridge # clone vm by zfs clone
    $tool_dir/zfs_vyos_config_setup.sh $num $VYOS_NETWORK_BRIDGE $group_network_bridge            # change cloned vm's config files
    $tool_dir/create_snapshot_zfs.sh $num $snapshot_name # create snapshot
    qm start $num &
done

pc_type='web'
for num in ${WEB_NUMS[@]}; do
    # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}"
    ip_address="192.168.${group_network_bridge}.${num:2:1}"
    snapshot_name="vm${num}_cloned_snapshot"
    _hostname="$pc_type$num"
    $tool_dir/zfs_clone_vm.sh $num $WEB_TEMP_NUM $_hostname $group_network_bridge
    $tool_dir/zfs_centos_config_setup.sh $num $ip_address $_hostname
    $tool_dir/create_snapshot_zfs.sh $num $snapshot_name # create snapshot
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
	mul_num=${num:0:1}
	mul_num=$((mul_num - 1))
	add_num=${num:2:1}
	add_num=$((add_num - 3))
	client_num=$((CLIENT_TEMP_NUM + student_per_group * mul_num + add_num))
        $tool_dir/zfs_clone_vm.sh $num $client_num $_hostname $group_network_bridge
    else
        $tool_dir/zfs_clone_vm.sh $num $CLIENT_TEMP_NUM $_hostname $group_network_bridge
    fi
    if [ $scenario_num -eq 1 ]; then
        $tool_dir/zfs_centos_config_setup.sh $num $ip_address $_hostname
    fi
    $tool_dir/create_snapshot_zfs.sh $num $snapshot_name # create snapshot
    qm start $num
done

# time measurement end
end_time=`date +%s`

time=$((end_time - start_time))
echo $time

# output logs
echo "[`date "+%Y/%m/%d %H:%M:%S"`] $0 $*" >> $LOG_FILE
echo " time              : $time [s]" >> $LOG_FILE
echo " scenario          : $scenario_num" >> $LOG_FILE
echo " group_num         : $group_num" >> $LOG_FILE
echo " router_template_vm: $VYOS_TEMP_NUM" >> $LOG_FILE
echo " router_vms:       : ${VYOS_NUMS[@]}" >> $LOG_FILE
echo " server_template_vm: $WEB_TEMP_NUM" >> $LOG_FILE
echo " server_vms:       : ${WEB_NUMS[@]}" >> $LOG_FILE
echo " client_template_vm: $CLIENT_TEMP_NUM" >> $LOG_FILE
echo " client_vms:       : ${CLIENT_NUMS[@]}" >> $LOG_FILE
echo >> $LOG_FILE
