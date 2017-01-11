#!/bin/bash

CMD="bash ./test.sh"
login_name='root'
password='cysec.lab'

expect -c "
set timeout 1000000
spawn qm terminal 615
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
"
