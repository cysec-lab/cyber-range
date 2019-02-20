#!/bin/bash
# 参考: https://www.tecmint.com/install-eclipse-oxygen-ide-in-centos-rhel-and-fedora/

eclipse_version='oxygen'

yum -y install wget
yum -y install java-1.8.0-openjdk-devel # eclise起動のために必要
result=`lscpu | grep 'Architecture' | grep 'x86_64'`
if [ ${#result} -ne 0 ]; then
    # 64bit
    linux_version='-x86_64'
else
    # 32bit
    linux_version=''
fi
eclipse_tar_file="eclipse-jee-$eclipse_version-R-linux-gtk${linux_version}.tar.gz"

wget http://ftp.fau.de/eclipse/technology/epp/downloads/release/$eclipse_version/R/$eclipse_tar_file

tar xfz $eclipse_tar_file -C /opt/
ls /opt/eclipse/
ln -s /opt/eclipse/eclipse /usr/local/bin/eclipse
ls -al /usr/local/bin/eclipse

# デスクトップのバーにeclipseを設置
cat << EOL > '/usr/share/applications/eclipse.desktop'
[Desktop Entry]
Name=Eclipse IDE
Comment=Eclipse IDE
Type=Application
Encoding=UTF-8
Exec=/usr/local/bin/eclipse
Icon=/opt/eclipse/icon.xpm
Categories=GNOME;Application;Development;
Terminal=false
StartupNotify=true
EOL
