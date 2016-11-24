#!/bin/sh

echo ***user***
cat /etc/passwd

echo *** openssl***
rpm -qa | grep openssl

echo ***OS***
cat /etc/redhat-release

echo ***bash***
rpm -qa | grep bash

echo ***crond_status***
/sbin/service crond status

echo ***cpu***
cat /proc/cpuinfo | grep processor | wc -l

echo ***memory***
cat /proc/meminfo | grep MemTotal

echo ***network***
cat /etc/sysconfig/network

echo ***hosts***
cat /etc/hosts

echo ***ifcfg-eth0***
cat /etc/sysconfig/network-scripts/ifconfig-eth0

#echo ***ifcfg-eth1***
#cat /etc/sysconfig/network-scripts/ifconfg-eth1

echo ***UDEV***
cat /etc/udev/rules.d/70-persistent-net.rules | \
  grep -v -e '^\s*#' -e '^\s*$'

echo ***resolv.conf***
cat /etc/resolv.conf

echo ***hosts.allow***
cat /etc/hosts.allow | grep -v -e '^\s*#'

#echo ***ntp***
#cat /etc/ntp.conf

echo ***hostname***
hostname

echo ***ifconfig***
/sbin/ifconfig

echo ***sshd_config***
cat /etc/ssh/sshd_config | \
  grep -v -e '^\s*#' -e '^\s*$'


