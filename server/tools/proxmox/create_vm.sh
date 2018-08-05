#!/bin/bash

# Need create vmid VM_NAME
if [ $# -ne 2 ]; then
  echo "Need [vmid] [VM_NAME]"
  echo "$0 [100]"
  exit
fi

NUM=$1
# TODO choose resource info
NAME=$2
FORMAT='qcow2'
SIZE=64
MEMORY=1024
SOCKETS=1
CORES=1


pvesh create /nodes/proxmox/storage/local/content -filename vm-${NUM}-disk-1.${FORMAT} -format ${FORMAT} -size ${SIZE}G -vmid ${ID}
pvesh create /nodes/proxmox/qemu -vmid ${NUM} -name ${NAME} -memory ${MEMORY} -sockets ${SOCKETS} -cores ${CORES} -net0 e1000,bridge=vmbr0 -ide0 local:${ID}/vm-${ID}-disk-1.${FORMAT} -ide2 local:iso/CentOS-6.7-x86_64-minimal.iso,media=cdrom
pvesh create /nodes/proxmox/qemu/${NUM}/status/start

#qm create $NUM --cdrom local:iso/${ISO} --name $VM_NAME 
#qm create 103 --cdrom nfs-iso:iso/debian-6.0.1-amd64-BD-1.iso --name squeeze-bd --vlan0 virtio=62:57:BC:A2:0E:18 --virtio0 tbdisk:10,format=raw --bootdisk virtio0 --ostype l26 --memory 512 --onboot no --sockets 1
