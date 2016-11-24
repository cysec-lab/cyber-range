#!/bin/sh

yum -y install epel-release
yum -y install --enablerepo=epel nsd

mv /etc/nsd/nsd.conf /etc/nsd/nsd.conf.bak
mv /root/nsd.conf /etc/nsd/
chcon --reference=/etc/nsd/nsd.conf.bak /etc/nsd/nsd.conf
#chcon -u system_u /etc/nsd/nsd.conf

mkdir /etc/nsd/zones
mv /root/0.168.192.in-addr.arpa.zone /etc/nsd/zones/
mv /root/cysec.local.zone /etc/nsd/zones/
restorecond -R /etc/nsd/zones

service nsd start
chkconfig nsd on

iptablefile='/etc/sysconfig/iptables'
dnsinfo="-A INPUT -m state --state NEW -m udp -p udp --dport 53 -j ACCEPT\n"
dnsinfo=${dnsinfo}"-A INPUT -m state --state NEW -m tcp -p tcp --dport 53 -j ACCEPT"

sed -i -e "/22/a ${dnsinfo}" ${iptablefile}

service iptables restart

reboot

