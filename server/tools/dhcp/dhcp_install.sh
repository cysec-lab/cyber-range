#!/bin/sh

yum -y install dhcp

mv /etc/dhcp/dhcp.conf /etc/dhcp/dhcp.conf.bak

# DHCPの情報変更
cat << EOT > /etc/dhcp/dhcp.conf

EOT

#chcon ??? /etc/dhcp/dhcp.conf
chmod 644 /etc/dhcp/dhcp.conf


service dhcpd start
chkconfig dhcpd on

reboot
