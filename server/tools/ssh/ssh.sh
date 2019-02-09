#!/bin/sh
# TODO: 引数で情報渡す

expect -c "
set timeout 5
spawn ssh root@192.168.0.13
expect \"Are you sure you want to continue connecting (yes/no)?\"
send \"yes\n\"
expect \"root@192.168.0.13\'s password:\"
send \"cysec.lab\\n\"
interact
"

