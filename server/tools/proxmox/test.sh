#!/bin/bash

VM_NUM=402
TEMPLATE_NUM=717
TEMPLATE_NAME="vg_717"
PC_TYPE="client"
#TEMPLATE_NAME="VolGroup"

#VM_NUM=401
#TEMPLATE_NUM=716
#TEMPLATE_NAME="vg_web713"
#PC_TYPE="web"
##TEMPLATE_NAME="VolGroup"


IP_ADDRESS="192.168.110.131"
NBD_NUM=0

./clone_vm.sh $PC_TYPE $TEMPLATE_NUM $VM_NUM

./normal_mount.sh $VM_NUM $TEMPLATE_NAME $NBD_NUM 
./normal_centos_config_setup.sh $VM_NUM $TEMPLATE_NAME $NBD_NUM

./clone.sh $VM_NUM $IP_ADDRESS test${VM_NUM}

./normal_umount.sh $VM_NUM $NBD_NUM

qm start $VM_NUM
