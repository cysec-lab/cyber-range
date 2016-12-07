#!/bin/sh

# install php7 httpd
tar zxvf apache_install.tar.gz
./apache_install.sh
rm apache_install.sh apache_install.tar.gz

# install mysql
tar zxvf mysql_install.tar.gz
./mysql_install.sh
rm mysql_install.tar.sh mysql_install.tar.gz

# sql_injection site
tar zxvf sql.tar.gz
./sql_db.sh
cp sql.php /var/www/html # mvするとファイルディスクリプタがおかしくなる
rm sql.phpsql_db.sh sql_db.sql sql.tar.gz first_user.sql users.sql

# xss_reflected site
tar zxvf xss_reflected.tar.gz
cp xss_reflected.php /var/www/html
rm xss_reflected.php xss_reflected.tar.gz

# TODO resetファイルを一つにする
# xss_stored site
tar zxvf xss_stored.tar.gz
./stored_db.sh
cp login.php logout.php xss_stored.php /var/www/html
rm login.php logout.php stored_db.sh stored_db.sql xss_stored.php xss_stored.tar.gz first_comment.sql guestbook.sql

# directory_traversal site
tar zxvf directory_traversal.tar.gz
cp readfile.php /var/www/html
rm create_document_directory.sh directory_traversal.tar.gz readfile.php

# TODO typo tar file
# TODO change search site not mail site
# command_execution site
tar zxvf command_execution.tar.gz
cp send_mail.php /var/www/html
rm command_execution.tar.gz send_mail.php
