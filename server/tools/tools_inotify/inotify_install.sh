#!/bin/sh
# TODO: chcon can't apply

yum -y install epel-release
yum --enablerepo=epel -y install inotify-tools

mv /root/inotifywait.conf /etc/
chcon -u system_u -t etc_t /etc/inotifywait.conf # chcon: can't apply partial context to unlabeled file '/etc/inotifywait.conf'

mv /root/inotifywait /etc/rc.d/init.d/
chcon -u system_u -t initrc_exec_t /etc/rc.d/init.d/inotifywait # chcon can't apply partial context to unlabeled file '/etc/rc.d/init.d/inotifywait
chmod 755 /etc/rc.d/init.d/inotifywait

service inotifywait start 

chkconfig --add inotifywait
chkconfig inotifywait on


