#!/bin/bash

PROXMOX_NUM=0
WEB_TEMP=0
CLIENT_TEMP=0
VYOS_TEMP=952

PROXMOX_MAX_NUM=9
STUDENTS_PER_GROUP=4
GROUP_MAX_NUM=8
VG_NAME='VolGroup'
LOG_FILE="./setup.log"

# TODO: 現在1のみ利用
PROXMOX_NUM=1
#read -p "proxmox number(0 ~ $PROXMOX_MAX_NUM): " proxmox_num
#if [ $proxmox -lt 0 ] || [ $PROXMOX_MAX_NUM -lt $proxmox_num ]; then
#    echo 'invalid'
#    exit 1
#else
#    PROXMOX_NUM=$proxmox_num
#fi
# 各グループのネットワークに接続しているbridge番号(=Proxmox番号)
VYOS_NETWORK_BRIDGE=$PROXMOX_NUM

# TODO: WEB_NUMとCLIENT_NUM割り当てのルール設定
read -p "group number(1 ~ $GROUP_MAX_NUM): " group_num
if [ $group_num -lt 1 ] || [ $GROUP_MAX_NUM -lt $group_num ]; then
    echo 'invalid'
    exit 1
else
    for g_num in `seq 1 $group_num`; do
        VYOS_NUM+=("${g_num}01")
        WEB_NUM+=("${g_num}02")
        for i in `seq 3 $((2 + $STUDENTS_PER_GROUP))`; do
            CLIENT_NUM+=("${g_num}0${i}")
        done
    done
fi

read -p "scenario number(1 or 2): " scenario_num
if [ $scenario_num -eq 1 ]; then
    WEB_TEMP=621
    CLIENT_TEMP=620
elif [ $scenario_num -eq 2 ]; then
    WEB_TEMP=621
    CLIENT_TEMP=922
else
    echo 'invalid'
    exit 1
fi

#VYOS_NUM=(611 621 631 641 651 661)
#WEB_NUM=(512 522 532 542 552 562)
#CLIENT_NUM=(513 514 515 516 523 524 525 526 533 534 535 536 543 544 545 546 553 554 555 556 563 564 565 566)

start_time=`date +%s`

pc_type='vyos'
for num in ${VYOS_NUM[@]}; do
    # bridgeのルール https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}"
    $WORK_DIR/clone_vm.sh $num $VYOS_TEMP $pc_type $VYOS_NETWORK_BRIDGE $group_network_bridge
    $WORK_DIR/vyos_config_setup.sh $num $VYOS_NETWORK_BRIDGE $group_network_bridge
    qm start $num &
done

pc_type='web'
for num in ${WEB_NUM[@]}; do
    # bridgeのルール https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}"
    ip_address="192.168.${group_network_bridge}.${num:2:1}"
    $WORK_DIR/zfs_clone_vm.sh $num $WEB_TEMP $pc_type $group_network_bridge
    $WORK_DIR/zfs_centos_config_setup.sh $num $ip_address $pc_type $VG_NAME
    qm start $num
done

pc_type='client'
for num in ${CLIENT_NUM[@]}; do
    # bridgeのルール https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge="1${PROXMOX_NUM}${num:0:1}"
    ip_address="192.168.${group_network_bridge}.${num:2:1}"
    $WORK_DIR/zfs_clone_vm.sh $num $CLIENT_TEMP $pc_type $group_network_bridge
    if [ $scenario_num -eq 1 ]; then
        $WORK_DIR/zfs_centos_config_setup.sh $num $ip_address $pc_type $VG_NAME
    fi
    qm start $num
done

end_time=`date +%s`

time=$((end_time - start_time))
echo $time

# ログ出力
echo "[`date "+%Y/%m/%d %H:%M:%S"`] $0 $*" >> $LOG_FILE
echo " time              : $time [s]" >> $LOG_FILE
echo " scenario          : $scenario_num" >> $LOG_FILE
echo " group_num         : $group_num" >> $LOG_FILE
echo " server_template_vm: $WEB_TEMP" >> $LOG_FILE
echo " server_vms:       : ${WEB_NUM[@]}" >> $LOG_FILE
echo " client_template_vm: $CLIENT_TEMP" >> $LOG_FILE
echo " client_vms:       : ${CLIENT_NUM[@]}" >> $LOG_FILE
echo >> $LOG_FILE
