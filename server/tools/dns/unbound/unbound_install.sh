#!/bin/sh

yum -y install unbound

mv /etc/unbound/unbound.conf /etc/unbound/unbound.conf.bak
mv /root/unbound.conf /etc/unbound/
chcon --reference=/etc/unbound/unbound.conf.bak /etc/unbound/unbound.conf

IPTABLEFILE='/etc/sysconfig/iptables'
DNSINFO="-A INPUT -m state --state NEW -m udp -p udp --dport 53 -j ACCEPT\n"
DNSINFO=${DNSINFO}"-A INPUT -m state --state NEW -m tcp -p tcp --dport 53 -j ACCEPT"

sed -i -e "/22/a ${DNSINFO}" $IPTABLEFILE 

service iptables restart

service unbound start
chkconfig unbound on

reboot

