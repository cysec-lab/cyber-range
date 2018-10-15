#!/bin/bash
# create cyber_range environment
# - clone type : zfs
# - scenario 1 : Ransomeware
# - scenario 2 : Dos Attack

tool_dir=/root/github/cyber_range/server/tools/proxmox

VYOS_NUMS=()   # vyos(software router os) nums array
WEB_NUMS=()    # web server nums array
CLIENT_NUMS=() # client pc nums array

PROXMOX_NUM=0 # initial Promox server number. RANGE: 0~9
WEB_TEMP=0    # initial web server template vm number. RANGE: 100~999
CLIENT_TEMP=0 # initial client pc template vm number. RANGE: 100~999
VYOS_TEMP=900 # initial vyos(software router os) template vm number. RANGE: 100~999

SCENARIO_NUM=4         # create scinario num.
PROXMOX_MAX_NUM=9      # Promox server upper limit
STUDENTS_PER_GROUP=4   # number of students in exercise per groups
GROUP_MAX_NUM=7        # group upper limit per Proxmox server
VG_NAME='VolGroup'     # Volume Group name
LOG_FILE="./setup.log" # log file name

# TODO: Now only use server number 1
PROXMOX_NUM=5
#read -p "proxmox number(0 ~ $PROXMOX_MAX_NUM): " proxmox_num
#if [ $proxmox -lt 0 ] || [ $PROXMOX_MAX_NUM -lt $proxmox_num ]; then
#    echo 'invalid'
#    exit 1
#else
#    PROXMOX_NUM=$proxmox_num
#fi

# bridge number of connectiong each group network(=Proxmox number)
# if proxmox number is 1. network address is 192.168.1.0/24
VYOS_NETWORK_BRIDGE=$PROXMOX_NUM

# TODO: Decide to WEB_NUMS and CLIENT_NUMS setting rules
#       Now, determinate same composition
read -p "group number(2 ~ $GROUP_MAX_NUM): " group_num
if [ $group_num -lt 1 ] || [ $GROUP_MAX_NUM -lt $group_num ]; then
    echo 'invalid'
    exit 1
fi

read -p "next scenario number(1 ~ $SCENARIO_NUM): " scenario_num
if [ $scenario_num -lt 1 ] || [ $SCENARIO_NUM -lt $scenario_num ]; then
    echo 'invalid'
    exit 1
else
    VYOS_NUMS+=("${group_num}${scenario_num}1") # vyos number is *01
    WEB_NUMS+=("${group_num}${scenario_num}2")  # web server number is *02
    for i in `seq 3 $((2 + $STUDENTS_PER_GROUP))`; do
        CLIENT_NUMS+=("${group_num}${scenario_num}${i}") # client pc number are *03 ~ *09
    done
fi

#read -p "scenario number(1 or 2): " scenario_num
#if [ $scenario_num -eq 1 ]; then
#    # scenario 1
#    WEB_TEMP=902    # template web server vm number
#    CLIENT_TEMP=901 # template client pc vm number
#elif [ $scenario_num -eq 2 ]; then
#    # scenario 2
#    WEB_TEMP=902    # template web server vm number
#    CLIENT_TEMP=955 # template client pc vm number
#else
#    echo 'invalid'
#    exit 1
#fi

# time measurement start
start_time=`date +%s`

# stop vms
for num in ${VYOS_NUMS[@]} ${WEB_NUMS[@]} ${CLIENT_NUMS[@]}; do
    stop_num=$((num - 10))
    qm stop $stop_num &
    qm start $num &
done

#pc_type='vyos'
#for num in ${VYOS_NUMS[@]}; do
#    snapshot_name="vm${num}_cloned_snapshot"
#    $tool_dir/rollback_snapshot.vm $num $snapshot_name # rollback snapshot
#    qm start $num
#done
#
#pc_type='web'
#for num in ${WEB_NUMS[@]}; do
#    snapshot_name="vm${num}_cloned_snapshot"
#    $tool_dir/rollback_snapshot.vm $num $snapshot_name # rollback snapshot
#    qm start $num
#done
#
#pc_type='client'
#for num in ${CLIENT_NUMS[@]}; do
#    snapshot_name="vm${num}_cloned_snapshot"
#    $tool_dir/rollback_snapshot.vm $num $snapshot_name # rollback snapshot
#    qm start $num
#done

# time measurement end
end_time=`date +%s`

time=$((end_time - start_time))
echo $time

# output logs
echo "[`date "+%Y/%m/%d %H:%M:%S"`] $0 $*" >> $LOG_FILE
echo " time              : $time [s]" >> $LOG_FILE
echo " scenario          : $scenario_num" >> $LOG_FILE
echo " group_num         : $group_num" >> $LOG_FILE
echo " router_template_vm: $VYOS_TEMP" >> $LOG_FILE
echo " router_vms:       : ${VYOS_NUMS[@]}" >> $LOG_FILE
echo " server_template_vm: $WEB_TEMP" >> $LOG_FILE
echo " server_vms:       : ${WEB_NUMS[@]}" >> $LOG_FILE
echo " client_template_vm: $CLIENT_TEMP" >> $LOG_FILE
echo " client_vms:       : ${CLIENT_NUMS[@]}" >> $LOG_FILE
echo >> $LOG_FILE
