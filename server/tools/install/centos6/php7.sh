#!/bin/sh

yum -y remove php-*

rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
yum install -y php70w php70w-common php70w-devel php70w-intl php70w-mysql php70w-mbstring php70w-gd php70w-pear php70w-mcrypt php70w-pdo
