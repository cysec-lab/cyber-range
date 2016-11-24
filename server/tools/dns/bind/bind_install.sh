#!/bin/sh

yum -y install bind bind-utils

yum -y install epel-release
yum -y install --enablerepo=epel named

mv /etc/named/named.conf /etc/named/named.conf.bak
mv /root/named.conf /etc/named/
chcon --reference=/etc/named/named.conf.bak /etc/named/named.conf
#chcon -u system_u /etc/named/named.conf

mkdir /etc/named/zones
mv /root/0.168.192.in-addr.arpa.zone /etc/named/zones/
mv /root/cysec.local.zone /etc/named/zones/
restorecond -R /etc/named/zones
#chcon -t named_zone_t 

service named start
chkconfig named on

iptablefile='/etc/sysconfig/iptables'
dnsinfo="-A INPUT -m state --state NEW -m udp -p udp --dport 53 -j ACCEPT\n"
dnsinfo=${dnsinfo}"-A INPUT -m state --state NEW -m tcp -p tcp --dport 53 -j ACCEPT"

sed -i -e "/22/a ${dnsinfo}" ${iptablefile}

service iptables restart

reboot

