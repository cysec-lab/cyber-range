#!/bin/bash

yum -y install wget
wget http://ftp.mozilla.org/pub/firefox/releases/45.0.2/linux-x86_64/ja/firefox-45.0.2.tar.bz2
tar xvjf firefox-45.0.2.tar.bz2
mv firefox /opt/

ln -s /opt/firefox/firefox /usr/bin/firefox

