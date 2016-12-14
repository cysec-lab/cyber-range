#TODO httpd.confのコメントアウトと空行はどうするか
#`echo grep -v -e '^\s*#' -e '\s*$'`
#!/bin/sh

HOSTNAME=`hostname`

yum -y install httpd httpd-manual
rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
yum install -y php70w php70w-common php70w-devel php70w-intl php70w-mysql php70w-mbstring php70w-gd php70w-pear php70w-mcry php70w-pdo

mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
sed -i -e "s/^ServerName.*$/ServerName ${HOSTNAME}/g" '/root/httpd.conf'
mv /root/httpd.conf /etc/httpd/conf/
chcon --reference=/etc/httpd/conf/httpd.conf.bak /etc/httpd/conf/httpd.conf
#chcon -u system_u -t httpd_config_t /etc/httpd/conf/httpd.conf

service httpd start
chkconfig httpd on

IPTABLEFILE='/etc/sysconfig/iptables'
HTTPINFO='-A INPUT -p tcp -m tcp --dport http -j ACCEPT'

sed -i -e "/22/a ${HTTPINFO}" ${IPTABLEFILE}
service iptables restart

