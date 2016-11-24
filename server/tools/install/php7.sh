#!/bin/sh

#TODO can't install php7 instead of installing php5
yum -y remove php-*
yum -y install --enablerepo=remi,remi-php70 php php-devel php-opcache php-mbstring php-mcrypt php-pdo php-gd php-mysqlnd php-pecl-xdebug php-fpm php-xml
