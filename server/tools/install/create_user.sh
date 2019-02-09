#!/bin/sh
# TODO: パスワードをどう渡すか

# Need user_name
if [ $# -ne 1 ]; then
  echo "Need user_name"
  echo "$0 [user_name]"
  exit 1
fi

USER_NAME=$1


useradd $USER_NAME

yum -y install expect
expect -c "
set timeout 5
spawn passwd $USER_NAME
expect \"New password:\"
send \"${USER_NAME}\n\"
expect \"Retype new password:\"
send \"${USER_NAME}\n\"
interact
"
