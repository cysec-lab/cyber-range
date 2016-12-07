#!/bin/sh

#TODO can't install php7 instead of installing php5
yum -y remove php-*

rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
yum install -y php70w php70w-common php70w-devel php70w-intl php70w-mysql php70w-mbstring php70w-gd php70w-pear php70w-mcry php70w-pdo
#yum -y install --enablerepo=remi,remi-php70 php php-devel php-opcache php-mbstring php-mcrypt php-pdo php-gd php-mysqlnd php-pecl-xdebug php-fpm php-xml
