#!/bin/sh

yum -y install bind

mv /etc/named.conf /etc/named.conf.bak
mv /root/named.conf /etc/
chcon --reference=/etc/named /etc/named/named.conf

service named start
chkconfig named on

iptablefile='/etc/sysconfig/iptables'
dnsinfo="-A INPUT -m state --state NEW -m udp -p udp --dport 53 -j ACCEPT\n"
dnsinfo=${dnsinfo}"-A INPUT -m state --state NEW -m tcp -p tcp --dport 53 -j ACCEPT"

sed -i -e "/22/a ${dnsinfo}" ${iptablefile}

service iptables restart

reboot

