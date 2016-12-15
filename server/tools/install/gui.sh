#!/bin/sh

FILENAME='/etc/inittab'
sed -i -e 's/id:3:initdefault:/id:5:initdefault:/g' $FILENAME

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
