#!/bin/sh

yum -y groupinstall "GNOME Desktop"
systemctl set-default graphical.target
reboot
