#!/bin/sh
text='test mail'
address='test@gmail.com'

echo $text | mail -s "mail test" -r test@centos.jp $address
