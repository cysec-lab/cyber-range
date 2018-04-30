#!/bin/bash
# create cyber_range environment
# - clone type : zfs
# - scenario 1 : Ransomeware
# - scenario 2 : Dos Attack

# TODO: Now, template vms number are fixed
PROXMOX_NUM=0 # initial Promox server number
WEB_TEMP=0    # initial web server template vm number
CLIENT_TEMP=0 # initial client pc template vm number
VYOS_TEMP=952 # initial vyos(software router os) template vm number

PROXMOX_MAX_NUM=9      # Promox server upper limit
STUDENTS_PER_GROUP=4   # number of students in exercise per groups
GROUP_MAX_NUM=8        # group upper limit per Proxmox server
VG_NAME='VolGroup'     # Volume Group name
LOG_FILE="./setup.log" # log file name

# TODO: Now only use server number 1
PROXMOX_NUM=1
#read -p "proxmox number(0 ~ $PROXMOX_MAX_NUM): " proxmox_num
#if [ $proxmox -lt 0 ] || [ $PROXMOX_MAX_NUM -lt $proxmox_num ]; then
#    echo 'invalid'
#    exit 1
#else
#    PROXMOX_NUM=$proxmox_num
#fi

# bridge number of connecting each group network(=Proxmox number)
# if proxmox number is 1. network address is 192.168.1.0/24
VYOS_NETWORK_BRIDGE=$PROXMOX_NUM

# TODO: Decide to WEB_NUM and CLIENT_NUM setting rules
#       Now, determinate same compositon
read -p "group number(1 ~ $GROUP_MAX_NUM): " group_num
if [ $group_num -lt 1 ] || [ $GROUP_MAX_NUM -lt $group_num ]; then
    echo 'invalid'
    exit 1
else
    for g_num in `seq 1 $group_num`; do
        VYOS_NUM+=("${g_num}01") # vyos number is *01
        WEB_NUM+=("${g_num}02")  # web server number is *02
        for i in `seq 3 $((2 + $STUDENTS_PER_GROUP))`; do
            CLIENT_NUM+=("${g_num}0${i}") # client pc number are *03 ~ *09
        done
    done
fi

read -p "scenario number(1 or 2): " scenario_num
if [ $scenario_num -eq 1 ]; then
    # scenario 1
    WEB_TEMP=621     # template web server vm number
    CLIENT_TEMP=620  # template client pc vm number
elif [ $scenario_num -eq 2 ]; then
    WEB_TEMP=621     # template web server vm number
    CLIENT_TEMP=922  # template client pc vm number
else
    echo 'invalid'
    exit 1
fi

start_time=`date +%s`

pc_type='vyos'
for num in ${VYOS_NUM[@]}; do
    # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}" # decide group netwrok bridge number
    $WORK_DIR/clone_vm.sh $num $VYOS_TEMP $pc_type $VYOS_NETWORK_BRIDGE $group_network_bridge # clone vm
    $WORK_DIR/vyos_config_setup.sh $num $VYOS_NETWORK_BRIDGE $group_network_bridge            # change cloned vm's config files
    qm start $num &
done

pc_type='web'
for num in ${WEB_NUM[@]}; do
    # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}" # decide group network bridge number
    ip_address="192.168.${group_network_bridge}.${num:2:1}" # new vm's ip address
    $WORK_DIR/zfs_clone_vm.sh $num $WEB_TEMP $pc_type $group_network_bridge # clone vm by zfs clone
    $WORK_DIR/zfs_centos_config_setup.sh $num $ip_address $pc_type $VG_NAME # change cloned vm's config files
    qm start $num
done

pc_type='client'
for num in ${CLIENT_NUM[@]}; do
    # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}" # decide group network bridge number
    ip_address="192.168.${group_network_bridge}.${num:2:1}" # new vm's ip address
    $WORK_DIR/zfs_clone_vm.sh $num $CLIENT_TEMP $pc_type $group_network_bridge # clone vm by zfs clone
    if [ $scenario_num -eq 1 ]; then
        $WORK_DIR/zfs_centos_config_setup.sh $num $ip_address $pc_type $VG_NAME #change cloned vm's config file
    fi
    qm start $num
done

end_time=`date +%s`

time=$((end_time - start_time))
echo $time

# output logs
echo "[`date "+%Y/%m/%d %H:%M:%S"`] $0 $*" >> $LOG_FILE
echo " time              : $time [s]" >> $LOG_FILE
echo " scenario          : $scenario_num" >> $LOG_FILE
echo " group_num         : $group_num" >> $LOG_FILE
echo " server_template_vm: $WEB_TEMP" >> $LOG_FILE
echo " server_vms:       : ${WEB_NUM[@]}" >> $LOG_FILE
echo " client_template_vm: $CLIENT_TEMP" >> $LOG_FILE
echo " client_vms:       : ${CLIENT_NUM[@]}" >> $LOG_FILE
echo >> $LOG_FILE
