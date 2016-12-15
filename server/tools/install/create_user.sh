#!/bin/sh

HOSTNAME=`hostname`

useradd ${HOSTNAME}

yum -y install expect
expect -c "
set timeout 5
spawn passwd ${HOSTNAME}
expect \"New password:\"
send \"${HOSTNAME}\n\"
expect \"Retype new password:\"
send \"${HOSTNAME}\n\"
interact
"
