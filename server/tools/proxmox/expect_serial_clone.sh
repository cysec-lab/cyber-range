#!/bin/bash
#TODO: 動作検証

if [ $# -ne 3 ]; then
    echo "serial console login [VM num] [VM IP] [HOSTNAME] need"
    echo "example:"
    echo "$0 500 192.168.110.xxx hostname"
    exit 1
fi

VM_NUM=$1
VM_IP=$2
HOSTNAME=$3

if [ `echo $HOSTNAME | grep 'web'` ]; then
    CMD="bash ./clone.sh $VM_IP $HOSTNAME"
else
    CMD="bash ./clone_gui_client.sh $VM_IP $HOSTNAME"
fi

login_name='root'
password='cysec.lab'

expect -c "
set timeout 1000000
spawn qm terminal $VM_NUM
expect \"starting serial terminal on interface serial0 (press control-O to exit)\"
send \"\n\"
expect \"login:\" {
    send \"$login_name\n\"
    expect \"Password:\"
    send \"$password\n\"
    expect \"#\"
    send \"$CMD\n\"
} \"#\" {
    send \"$CMD\n\"
}
interact
EOF
"
