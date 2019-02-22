#!/bin/bash
# Proxmox環境構築時に実行するスクリプト

if [ $# -ne 1 ]; then
    echo "[proxmox num] need"
    echo "example:"
    echo "$0 3"
    exit 1
fi

# ブリッジの作成
cat << EOL >> /etc/network/interfaces

auto vmbr$PROXMOX_NUM
iface vmbr$PROXMOX_NUM inet static
    address 192.168.${PROXMOX_NUM}.254
    netwmask 255.255.255.0
    bridge_ports none
    bridge_stp off
    bridge_fd 0

auto vmbr1${PROXMOX_NUM}1 inet static
    address 192.168.1${PROXMOX_NUM}1.254
    netmask 255.255.255.0
    bridge_ports none
    bridge_stp off
    bridge_fd 0

auto vmbr1${PROXMOX_NUM}2 inet static
    address 192.168.1${PROXMOX_NUM}2.254
    netmask 255.255.255.0
    bridge_ports none
    bridge_stp off
    bridge_fd 0

auto vmbr1${PROXMOX_NUM}3 inet static
    address 192.168.1${PROXMOX_NUM}3.254
    netmask 255.255.255.0
    bridge_ports none
    bridge_stp off
    bridge_fd 0

auto vmbr1${PROXMOX_NUM}4 inet static
    address 192.168.1${PROXMOX_NUM}4.254
    netmask 255.255.255.0
    bridge_ports none
    bridge_stp off
    bridge_fd 0

auto vmbr1${PROXMOX_NUM}5 inet static
    address 192.168.1${PROXMOX_NUM}5.254
    netmask 255.255.255.0
    bridge_ports none
    bridge_stp off
    bridge_fd 0

auto vmbr1${PROXMOX_NUM}6 inet static
    address 192.168.1${PROXMOX_NUM}6.254
    netmask 255.255.255.0
    bridge_ports none
    bridge_stp off
    bridge_fd 0

auto vmbr1${PROXMOX_NUM}7 inet static
    address 192.168.1${PROXMOX_NUM}7.254
    netmask 255.255.255.0
    bridge_ports none
    bridge_stp off
    bridge_fd 0

auto vmbr1${PROXMOX_NUM}8 inet static
    address 192.168.1${PROXMOX_NUM}8.254
    netmask 255.255.255.0
    bridge_ports none
    bridge_stp off
    bridge_fd 0

auto vmbr1${PROXMOX_NUM}9 inet static
    address 192.168.1${PROXMOX_NUM}9.254
    netmask 255.255.255.0
    bridge_ports none
    bridge_stp off
    bridge_fd 0

EOL
