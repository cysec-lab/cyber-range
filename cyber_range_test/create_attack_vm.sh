#!/bin/bash
# create cyber_range environment
# - clone type : full
# - scenario 1 : Ransomeware
# - scenario 2 : Dos Attack

tool_dir=/root/github/cyber_range/server/tools/proxmox

WEB_TEMP=952    # initial web server template vm number. RANGE: 100~999

PROXMOX_MAX_NUM=9         # Promox server upper limit
STUDENTS_PER_GROUP=4      # number of students in exercise per groups
GROUP_MAX_NUM=7           # group upper limit per Proxmox server
TARGET_STRAGE='local-zfs' # full clone target strage
VG_NAME='VolGroup'        # Volume Group name
LOG_FILE="./setup.log"    # log file name

PROXMOX_NUM=5

#WEB_NUMS=(981 982 983 984 985 986 987)
WEB_NUMS=(989)

# bridge number of connecting each group network(=Proxmox number)
# if proxmox number is 1. network address is 192.168.1.0/24
VYOS_NETWORK_BRIDGE=$PROXMOX_NUM

pc_type='web'
for num in ${WEB_NUMS[@]}; do
    # bridge rules https://sites.google.com/a/cysec.cs.ritsumei.ac.jp/local/shareddevices/proxmox/network
    group_network_bridge=5
    ip_address="192.168.${group_network_bridge}.${num:1:2}"
    $tool_dir/clone_vm.sh $num $WEB_TEMP $pc_type $TARGET_STRAGE $group_network_bridge
    $tool_dir/zfs_centos_config_setup.sh $num $ip_address $pc_type $VG_NAME # change cloned vm's config files
    #$tool_dir/disk_mount.sh $num $ip_address $pc_type $VG_NAME
    #$tool_dir/uuid_setup.sh $num $ip_address $pc_type $VG_NAME
    #$tool_dir/centos_config_setup.sh $num $ip_address $pc_type $VG_NAME
    #$tool_dir/nfs_setup.sh $num $ip_address $pc_type
    #$tool_dir/disk_umount.sh $num $ip_address $pc_type $VG_NAME
    qm start $num &
done
