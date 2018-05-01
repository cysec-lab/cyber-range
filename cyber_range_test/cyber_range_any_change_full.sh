#!/bin/bash

VYOS_NUM=()
WEB_NUM=()
CLIENT_NUM=()

PROXMOX_NUM=0
WEB_TEMP=0
CLIENT_TEMP=0
VYOS_TEMP=952

PROXMOX_MAX_NUM=9
STUDENTS_PER_GROUP=4
GROUP_MAX_NUM=8
VG_NAME='VolGroup'
LOG_FILE="./setup.log"

# TODO: Now only use server number 1
PROXMOX_NUM=1
#read -p "proxmox number(0 ~ $PROXMOX_MAX_NUM): " proxmox_num
#if [ $proxmox -lt 0 ] || [ $PROXMOX_MAX_NUM -lt $proxmox_num ]; then
#    echo 'invalid'
#    exit 1
#else
#    PROXMOX_NUM=$proxmox_num
#fi

# bridge number of connectiong each group network(=Proxmox number)
VYOS_NETWORK_BRIDGE=$PROXMOX_NUM

# TODO: Decide to WEB_NUM and CLIENT_NUM setting rules
#       Now, determinate same composition
read -p "group number(1 ~ $GROUP_MAX_NUM): " group_num
if [ $group_num -lt 1 ] || [ $GROUP_MAX_NUM -lt $group_num ]; then
    echo 'invalid'
    exit 1
else
    VYOS_NUM+=("${group_num}01")
    WEB_NUM+=("${group_num}02")
    for i in `seq 3 $((2 + $STUDENTS_PER_GROUP))`; do
        CLIENT_NUM+=("${group_num}0${i}")
    done
fi

read -p "scenario number(1 or 2): " scenario_num
if [ $scenario_num -eq 1 ]; then
    WEB_TEMP=618
    CLIENT_TEMP=617
elif [ $scenario_num -eq 2 ]; then
    WEB_TEMP=618
    CLIENT_TEMP=921
else
    echo 'invalid'
    exit 1
fi

# time measurement start
start_time=`date +%s`

# delete before vms
for num in ${VYOS_NUM[@]} ${WEB_NUM[@]} ${CLIENT_NUM[@]}; do 
    $WORK_DIR/delete_vm.sh $num
done

pc_type='vyos'
for num in ${VYOS_NUM[@]}; do
    # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}"
    $WORK_DIR/clone_vm.sh $num $VYOS_TEMP $pc_type $VYOS_NETWORK_BRIDGE $group_network_bridge
    $WORK_DIR/vyos_config_setup.sh $num $VYOS_NETWORK_BRIDGE $group_network_bridge
    qm start $num &
done

pc_type='web'
for num in ${WEB_NUM[@]}; do
    # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}"
    ip_address="192.168.${group_network_bridge}.${num:2:1}"
    $WORK_DIR/clone_vm.sh $num $WEB_TEMP $pc_type $group_network_bridge
    $WORK_DIR/disk_mount.sh $num $ip_address $pc_type $VG_NAME
    $WORK_DIR/uuid_setup.sh $num $ip_address $pc_type $VG_NAME
    $WORK_DIR/centos_config_setup.sh $num $ip_address $pc_type $VG_NAME
    $WORK_DIR/nfs_setup.sh $num $ip_address $pc_type
    $WORK_DIR/disk_umount.sh $num $ip_address $pc_type $VG_NAME
    qm start $num &
done

pc_type='client'
for num in ${CLIENT_NUM[@]}; do
    # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}"
    ip_address="192.168.${group_network_bridge}.${num:2:1}"
    $WORK_DIR/clone_vm.sh $num $CLIENT_TEMP $pc_type $group_network_bridge
    if [ $scenario_num -eq 1 ]; then
        $WORK_DIR/disk_mount.sh $num $ip_address $pc_type $VG_NAME
        $WORK_DIR/uuid_setup.sh $num $ip_address $pc_type $VG_NAME
        $WORK_DIR/centos_config_setup.sh $num $ip_address $pc_type $VG_NAME
        $WORK_DIR/nfs_setup.sh $num $ip_address $pc_type
        $WORK_DIR/disk_umount.sh $num $ip_address $pc_type $VG_NAME
    fi
    qm start $num &
done

# time measurement end
end_time=`date +%s`

time=$((end_time - start_time))
echo $time

# output logs
echo "[`date "+%Y/%m/%d %H:%M:%S"`] $0 $*" >> $LOG_FILE
echo " time              : $time [s]" >> $LOG_FILE
echo " scenario          : $scenario_num" >> $LOG_FILE
echo " server_template_vm: $WEB_TEMP" >> $LOG_FILE
echo " server_vms:       : ${WEB_NUM[@]}" >> $LOG_FILE
echo " client_template_vm: $CLIENT_TEMP" >> $LOG_FILE
echo " client_vms:       : ${CLIENT_NUM[@]}" >> $LOG_FILE
echo >> $LOG_FILE