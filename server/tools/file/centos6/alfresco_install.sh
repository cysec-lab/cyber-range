#!/bin/sh

yum -y install libXrender libICE libSM libXext fontconfig cups-libs

IPADDRLINE=`ifconfig | grep 'inet addr:192'`
IPADDR=${IPADDRLINE#*:}

IPTABLEFILE='/etc/sysconfig/iptables'
FILEINFO='-A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT\n'
FILEINFO=${FILEINFO}'-A INPUT -m state --state NEW -m tcp -p tcp --dport 8443 -j ACCEPT\n'
FILEINFO=${FILEINFO}'-A INPUT -m state --state NEW -m tcp -p tcp --dport 7070 -j ACCEPT'
sed -i -e "/22/a ${FILEINFO}" ${IPTABLEFILE}
service iptables restart

# GUI環境でする必要がある？ 入れない方針で行きたい
#yum -y groupinstall "X Window System" "Desktop" "General Purpose Desktop"
#sed -i -e "s/^id:[0-6]/id:5/" /etc/inittab


yum -y install expect

# Refere qiita.com/dogyeari/items/e58ddab9a49bf82ed43f
expect -c "
set timeout 5
spawn /root/alfresco-community-installer-linux-x64.bin
expect \"Do you want to continue with the installation\"
send -- \"y\\n\"
expect \"Please choose an option\"
send -- \"1\\n\"
expect \"Please choose an option\"
send -- \"2\\n\"
expect \"Java\"
send -- \"Y\\n\"
expect \"PostgreSQL\"
send -- \"Y\\n\"
expect \"LibreOffice\"
send -- \"Y\\n\"
expect \"Solr1\"
send -- \"N\\n\"
expect \"Solr4\"
send -- \"Y\\n\"
expect \"Alfresco Office Services\"
send -- \"Y\\n\"
expect \"Web Quick Start\"
send -- \"y\\n\"
expect \"Google Docs Integration\"
send -- \"Y\\n\"
expect \"Is the selection above correct?\"
send -- \"Y\\n\"
expect \"Select a folder:\"
send -- \"/opt/alfresco\\n\"
expect \"Database Server Port:\"
send -- \"\\n\"
expect \"Web Server domain:\"
send -- \"${IPADDR%Bcast*}\\n\"
expect \"Tomcat Server Port:\"
send -- \"\\n\"
expect \"Tomcat Shutdown Port:\"
send -- \"\\n\"
expect \"Tomcat SSL Port:\"
send -- \"\\n\"
expect \"Tomcat AJP Port:\"
send -- \"\\n\"
expect \"LibreOffice Server Port:\"
send -- \"\\n\"
expect \"Port:\"
send -- \"\\n\"
expect \"Admin Password:\"
send -- \"cysec.lab\\n\"
expect \"Repeat Password:\"
send -- \"cysec.lab\\n\"
expect \"Install Alfresco Community as a service ?\"
send -- \"Y\\n\"
expect \"to continue:\"
send -- \"\\n\"
expect \"Do you want to continue?\"
send -- \"Y\\n\"
expect \"View Readme File\"
send -- \"n\\n\"
expect \"Launch Alfresco Community\"
send -- \"Y\\n\"
"

