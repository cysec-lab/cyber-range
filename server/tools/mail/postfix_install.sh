#!/bin/sh

IPTABLEFILE='/etc/sysconfig/iptables'
MAILINFO="-A INPUT -p tcp -m tcp --dport smtp -j ACCEPT\n"
MAILINFO=${MAILINFO}"-A INPUT -p tcp -m tcp --dport pop3 -j ACCEPT"

sed -i -e "/22/a ${MAILINFO}" ${IPTABLEFILE}

service iptables restart

HOSTNAME=`hostname`

mv /etc/postfix/main.cf /etc/postfix/main.cf.bak
sed -i -e "s/^myhostname.*$/myhostname = ${HOSTNAME}/g" '/root/main.cf'
mv /root/main.cf /etc/postfix/
chcon --reference=/etc/postfix/main.cf.bak /etc/postfix/main.cf
#chcon -u system_u -t postfix_etc_t /etc/postfix/main.cf

yum -y install dovecot
mv /etc/dovecot/conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf.bak
mv /root/10-mail.conf /etc/dovecot/conf.d/
chcon --reference/etc/dovecot/conf.d/10-mail.conf.bak /etc/dovecot/conf.d/10-mail.conf

#chcon -u system_u -t dovecot_etc_t /etc/dovecot/conf.d/10-mail.conf

service dovecot start
chkconfig dovecot on

reboot

