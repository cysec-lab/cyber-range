#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

configure

set interfaces ethernet eth0
set interfaces ethernet eth0 address '192.168.100.240/24'

set interfaces ethernet eth1
set interfaces ethernet eth1 address '192.168.50.1/24'

#set service ssh port '22'

set nat source rule 100 outbound-interface 'eth0'
set nat source rule 100 source address '192.168.50.0/24'
set nat source rule 100 translation address masquerade

set protocols rip network '192.168.100/0/24'
set protocols rip redistribute connected 

set service dns forwarding cache-size '150'
set service dns forwarding listen-on 'eth1'
set service dns forwarding name-server '8.8.8.8'

set system login user vyos authentication plaintext-passwrd 'cysec.lab'

set system time-zone 'Asia/Tokyo'

commit 
save
