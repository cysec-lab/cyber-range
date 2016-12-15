#!/bin/vbash

if [ $# -ne 2 ]; then
    echo "need eth0 eth1 IP address"
    echo "./setup.sh [eth0 Address] [eth1 Address]"
    exit 1
fi
eth0=$1 # コンフィグレーションモードに入る前に引数を別の変数に代入して使用
eth1=$2


#### コンフィグレーションモード
source /opt/vyatta/etc/functions/script-template
configure

#set interfaces ethernet eth0
delete interfaces ethernet eth0 address
set interfaces ethernet eth0 address "$eth0/24"

#set interfaces ethernet eth1
delete interfaces ethernet eth1 address 
set interfaces ethernet eth1 address "$eth1/24"


#set nat source rule 100 outbound-interface 'eth0'
delete nat source rule 100 source address
set nat source rule 100 source address "${eth1%.*}.0/24"
#set nat source rule 100 translation address masquerade

delete protocols rip network
set protocols rip network "${eth0%.*}.0/24"
#set protocols rip redistribute connected 

#set service dns forwarding cache-size '150'
#set service dns forwarding listen-on 'eth1'
#set service dns forwarding name-server '8.8.8.8'

#set service ssh port '22'

#set system time-zone 'Asia/Tokyo'

commit 
save
