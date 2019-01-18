#!/bin/bash

tool_dir=/root/github/cyber_range/server/tools/proxmox

ZFS_TEMPLATE_VMS=(965 966 967 968 969 975 976 977 978 979)
FULL_TEMPLATE_VMS=(980 981 982 983 984 985 986 987 988 989)

MODE=('r' 'w')

file='./vm_info.json'
zfs_before_vm=965
full_before_vm=980

SLEEP_TIME=60 # sleep する時間，適当に考えてる

MEASURE_SCRIPT='/root/github/cyber_range/server/tools/utilities/dummy_data_log/fire_measure_dummy_data.sh'

# スナップショットの削除
#for zfs_vm in ${ZFS_TEMPLATE_VMS[@]}; do
#    result=`zfs list -t snapshot | grep $zfs_vm`
#    for snapshot in $result; do
#        if [ `echo $snapshot | grep '@'` ]; then
#            zfs destroy $snapshot
#        fi
#    done
#done

## 実験環境構築
#for (( i = 0; i < 5; i++ )); do
#    ## run zfsスクリプト
#    sysctl -w vm.drop_caches=3
#    bash ./cyber_range_all_setup_zfs.sh
#    echo "sleep ${SLEEP_TIME}s"
#    sleep $SLEEP_TIME
#    sysctl -w vm.drop_caches=3
#    bash ./cyber_range_all_delete.sh
#    echo "sleep ${SLEEP_TIME}s"
#    sleep $SLEEP_TIME
#        
#    # run fullスクリプト
#    sysctl -w vm.drop_caches=3
#    bash ./cyber_range_all_setup_full.sh
#    echo "sleep ${SLEEP_TIME}s"
#    sleep $SLEEP_TIME
#    sysctl -w vm.drop_caches=3
#    bash ./cyber_range_all_delete.sh
#    echo "sleep ${SLEEP_TIME}s"
#    sleep $SLEEP_TIME
#    
#done

# ダミーデータ環境構築
for (( i = 0; i < 5; i++ )); do
    for mode in ${MODE[@]}; do
        j=0
        for zfs_vm in ${ZFS_TEMPLATE_VMS[@]}; do
            full_vm=${FULL_TEMPLATE_VMS[$j]]}

            # vm_info.jsonを編集
            sed -ie "s/$zfs_before_vm/$zfs_vm/g" $file
            sed -ie "s/$full_before_vm/$full_vm/g" $file

            ## run zfsスクリプト
            sysctl -w vm.drop_caches=3
            bash ./cyber_range_all_setup_zfs.sh
            echo "sleep ${SLEEP_TIME}s"
            sleep $SLEEP_TIME
            $MEASURE_SCRIPT $mode 1 zfs $j
            sysctl -w vm.drop_caches=3
            bash ./cyber_range_all_delete.sh
            
            # run fullスクリプト
            sysctl -w vm.drop_caches=3
            bash ./cyber_range_all_setup_full.sh
            echo "sleep ${SLEEP_TIME}s"
            sleep $SLEEP_TIME
            $MEASURE_SCRIPT $mode 1 full $j
            sysctl -w vm.drop_caches=3
            bash ./cyber_range_all_delete.sh
        
            # before vmの更新
            zfs_before_vm=$zfs_vm
            full_before_vm=$full_vm

            j=$(( j + 1 ))
        done
    done
done
# vm_info.jsonを編集 初期状態に戻す
sed -ie "s/$zfs_before_vm/${ZFS_TEMPLATE_VMS[0]}/g" $file
sed -ie "s/$full_before_vm/${FULL_TEMPLATE_VMS[0]}/g" $file

#i=0
#pc_type='web'
#for num in ${FULL_TEMPLATE_VMS[@]}; do
#    group_network_bridge="1"
#    ip_address="192.168.${group_network_bridge}.${num:1:2}"
#    template_num=${ZFS_TEMPLATE_VMS[$i]]}
#    VG_NAME="vg_$template_num"
#    pc_type=`cat "/etc/pve/qemu-server/${template_num}.conf" | grep -m 1 "name"`
#    pc_type=${pc_type%$template_num*}
#    pc_type=${pc_type#* }
#    $tool_dir/clone_vm.sh $num $template_num $pc_type local $group_network_bridge
#    $tool_dir/change_format.sh $num
#    $tool_dir/disk_mount.sh $num $ip_address $pc_type $VG_NAME
#    $tool_dir/uuid_setup.sh $num $ip_address $pc_type $VG_NAME
#    $tool_dir/centos_config_setup.sh $num $ip_address $pc_type $VG_NAME
#    $tool_dir/nfs_setup.sh $num $ip_address $pc_type
#    $tool_dir/disk_umount.sh $num $ip_address $pc_type $VG_NAME
#    i=$(( i + 1 ))
#done

#for num in ${FULL_TEMPLATE_VMS[@]}; do
#    $tool_dir/delete_vm.sh $num
#done
