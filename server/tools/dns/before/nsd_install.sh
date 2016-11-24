#!/bin/sh

# refere https://blog.kteru.net/try-nsd400b1/
# refere yutarommx.com/?p=448
`echo "yum -y install wget gcc openssl-devel"`
`echo "cd /usr/local/src"`
`echo "wget http://nlnetlabs.nl/downloads/nsd/nsd-4.1.9.tar.gz"`
`echo "tar zxvf nsd-4.1.9.tar.gz"`
`echo "cd nsd-4.1.9"` 
`echo "./configure --prefix=/usr/local/nsd --with-libevent=no"`
`echo "make && make install"`

