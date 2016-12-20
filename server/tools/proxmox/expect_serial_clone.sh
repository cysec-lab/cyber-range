#!/bin/bash

if [ $# -ne 3 ]; then
    echo "serial console login [VM num] [VM IP] [HOSTNAME] need"
    echo "example:"
    echo "./expect_serial_login.sh 500 192.168.110.xxx hostname"
    exit 1
fi

VM_NUM=$1
VM_IP=$2
HOSTNAME=$3

login_name='root'
password='cysec.lab'

expect -c "
set timeout 5
spawn qm terminal $VM_NUM
expect \"starting serial terminal on interface serial0 (press control-O to exit)\"
send \"\n\"
expect \"login:\" {
    send \"$login_name\n\"
    expect \"Password:\"
    send \"$password\n\"
} 
expect \"#\"
send \"./clone.sh $VM_IP $HOSTNAME\n\"
interact
"
