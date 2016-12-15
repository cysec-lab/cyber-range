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

delete system console device ttyS0

#set interfaces ethernet eth0
#set interfaces ethernet eth0 address "$eth0/24"

#set service ssh port '22'

# need to add network device
set interfaces ethernet eth1
set interfaces ethernet eth1 address "$eth1/24"
set nat source rule 100 outbound-interface 'eth0'
set nat source rule 100 source address "${eth1%.*}.0/24"
set nat source rule 100 translation address masquerade

set protocols rip network "${eth0%.*}.0/24"
set protocols rip redistribute connected 

set service dns forwarding cache-size '150'
set service dns forwarding listen-on 'eth1'
set service dns forwarding name-server '8.8.8.8'


set system time-zone 'Asia/Tokyo'

commit 
save


#### オペレーション
### setup myself
# install image
## Would you like to continue? (Yes/No) [Yes]: [return]
## Partition (Auto/Parted/Skip) [Auto]: [return] 
## Install the image on? [sda]: [return]
## Continue? (Yes/No) [No]: Yes
## How big of a root partition should I create? (1000MB – 34359MB) [34359]MB: [return]
## What would you like to name this image? [1.1.7]: [return]
## Which one should I copy to sda? [/config/config.boot]: [return]
## Enter password for user 'vyos': 設定したいパスワード
## Retype password for user 'vyos': 上で入力したパスワード
## Which drive should GRUB modify the boot partition on? [sda]: [return]

# set console keymap
## IBM Space Saver
## Other -> Japan -> Japan
## The default for the keyboard layout
## No compose key

