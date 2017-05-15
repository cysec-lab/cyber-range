pvesh create /nodes/proxmox/storage/local/content -filename vm-106-disk-1.qcow2 -format qcow2 -size 64G -vmid 106
pvesh create /nodes/proxmox/qemu -vmid 106 -memory 1024 -sockets 1 -cores 1 -net0 e1000,bridge=vmbr0 -ide0 local:106/vm-106-disk-1.qcow2 -ide2 local:iso/CentOS-6.7-x86_64-minimal.iso,media=cdrom
pvesh create /nodes/proxmox/qemu/106/status/start

