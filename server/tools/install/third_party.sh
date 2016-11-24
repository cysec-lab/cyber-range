#!/bin/sh

# epel-relase
yum -y install epel-release
# Remi 
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

## epel-release install
#rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
#rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
#
## rpmforge-release install
#rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
#rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm

