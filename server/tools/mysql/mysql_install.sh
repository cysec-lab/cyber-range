#!/bin/sh
# can't use [] character
# TODO: 以下の行で止まる
#       expect \"Remove test database and access to it?\"


yum -y install http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
yum -y install mysql-server

FORMAT_INFO='character-set-server=utf8'
FORMAT_FILE='/etc/my.cnf'
sed -i -e "/symbolic-links=0/a ${FORMAT_INFO}" ${FORMAT_FILE}

service mysqld start
chkconfig mysqld on

yum -y install expect
expect -c "
set timeout 5
spawn mysql_secure_installation
expect  \"Enter current password for root (enter for none):\"
send \"\\n\"
expect \"Set root password?\"
send \"Y\\n\"
expect \"New password:\"
send \"cysec.lab\\n\"
expect \"Re-enter new password:\"
send \"cysec.lab\\n\"
expect \"Remove anonymous users?\"
send \"Y\\n\"
expect \"Disallow root login remoteley?\"
send \"Y\\n\"
expect \"Remove test database and access to it?\"
send \"Y\\n\"
expect \"Reload privilege tables now?\"
send \"Y\\n\"
interact
"
