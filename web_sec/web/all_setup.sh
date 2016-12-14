#!/bin/sh

# SELinux off
FILENAME='/etc/selinux/config'
sed -i -e "s/SELINUX=enforcing/SELINUX=disabled/g" $FILENAME

# install php7 httpd
tar zxvf apache_install.tar.gz
./apache_install.sh
rm apache_install.sh apache_install.tar.gz

# install mysql
tar zxvf mysql_install.tar.gz
./mysql_install.sh
rm mysql_install.sh mysql_install.tar.gz

# sql_injection site
tar zxvf sql.tar.gz
./sql_db.sh
cp sql.php /var/www/html # mvするとファイルディスクリプタがおかしくなる
rm sql.php sql_db.sh sql_db.sql sql.tar.gz first_user.sql users.sql

# xss_reflected site
tar zxvf xss_reflected.tar.gz
cp xss_reflected.php /var/www/html
rm xss_reflected.php xss_reflected.tar.gz

# TODO resetファイルを一つにする
# TODO login.phpに問題あり
# xss_stored site
tar zxvf xss_stored.tar.gz
./login_db.sh
./stored_db.sh
cp login.php logout.php xss_stored.php /var/www/html
rm lobin_db.sh login_db.sql login_users.sql default_users.sql login.php logout.php stored_db.sh stored_db.sql xss_stored.php xss_stored.tar.gz first_comment.sql guestbook.sql 

# directory_traversal site
tar zxvf directory_traversal.tar.gz
./create_document_directory.sh
cp readfile.php /var/www/html
rm create_document_directory.sh directory_traversal.tar.gz readfile.php open_document.txt secret_document.txt

# command_execution site
tar zxvf command_execution.tar.gz
cp send_mail.php /var/www/html
rm command_execution.tar.gz send_mail.php

rm web_cybar_range.tar.gz

# refere selinux
reboot
