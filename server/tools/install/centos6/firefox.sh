#!/bin/bash
# 以下をwgetすると最新版を落としてこれる
# 64bit https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=ja
# 32bit https://download.mozilla.org/?product=firefox-latest-ssl&os=linux&lang=ja

# CentOS6ではversion46.0.1以上を動かすためにはGTK3に対応する必要がある
firefox_version='45.0.2' # ここのバージョンを変更するとインストールされるバージョンが変わる
firefox_tar_file="firefox-${firefox_version}.tar.bz2"

yum -y install wget
result=`lscpu | grep 'Architecture' | grep 'x86_64'`
if [ ${#result} -ne 0 ]; then
    # 64bit
    linux_version='linux-x86_64'
else
    # 32bit
    linux_version='linux-i686'
fi

wget http://ftp.mozilla.org/pub/firefox/releases/$firefox_version/$linux_version/ja/$firefox_tar_file
tar xvjf $firefox_tar_file
rm $firefox_tar_file
mv firefox /opt/

ln -s /opt/firefox/firefox /usr/bin/firefox
