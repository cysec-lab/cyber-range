#!/bin/bash
# Proxmoxのブリッジ作成

CONF_FILE='/etc/network/interfaces'

result=`printenv $PROXMOX_NUM`
if [ ${#result} -ne 0 ]; then
    echo '環境変数PROXMOX_NUMにProxmoxのサーバ番号を格納してください'
    exit 1
fi

sed -i -e "s/vmbr0/vmbr100/g" $CONF_FILE

# ブリッジの作成
cat << EOL >> $CONF_FILE

auto vmbr$PROXMOX_NUM
iface vmbr$PROXMOX_NUM inet static
        address 192.168.${PROXMOX_NUM}.254
        netwmask 255.255.255.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0

auto vmbr1${PROXMOX_NUM}1
iface vmbr1${PROXMOX_NUM}1 inet static
        address 192.168.1${PROXMOX_NUM}1.254
        netmask 255.255.255.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0

auto vmbr1${PROXMOX_NUM}2
iface vmbr1${PROXMOX_NUM}2 inet static
        address 192.168.1${PROXMOX_NUM}2.254
        netmask 255.255.255.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0

auto vmbr1${PROXMOX_NUM}3
iface vmbr1${PROXMOX_NUM}3 inet static
        address 192.168.1${PROXMOX_NUM}3.254
        netmask 255.255.255.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0

auto vmbr1${PROXMOX_NUM}4
iface vmbr1${PROXMOX_NUM}4 inet static
        address 192.168.1${PROXMOX_NUM}4.254
        netmask 255.255.255.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0

auto vmbr1${PROXMOX_NUM}5
iface vmbr1${PROXMOX_NUM}5 inet static
        address 192.168.1${PROXMOX_NUM}5.254
        netmask 255.255.255.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0

auto vmbr1${PROXMOX_NUM}6
iface vmbr1${PROXMOX_NUM}6 inet static
        address 192.168.1${PROXMOX_NUM}6.254
        netmask 255.255.255.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0

auto vmbr1${PROXMOX_NUM}7
iface vmbr1${PROXMOX_NUM}7 inet static
        address 192.168.1${PROXMOX_NUM}7.254
        netmask 255.255.255.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0

auto vmbr1${PROXMOX_NUM}8
iface vmbr1${PROXMOX_NUM}8 inet static
        address 192.168.1${PROXMOX_NUM}8.254
        netmask 255.255.255.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0

auto vmbr1${PROXMOX_NUM}9
iface vmbr1${PROXMOX_NUM}9 inet static
        address 192.168.1${PROXMOX_NUM}9.254
        netmask 255.255.255.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0

EOL
