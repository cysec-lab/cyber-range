#!/bin/bash
#
#create a file to work with
#
echo "creating a file to work with"
dd if=/dev/zero of=/var/tmp/infile count=1175000

for bs in  16M 32M 64M 128M 256M 512M 1G 2G 4G

do
        echo "---------------------------------------"
        echo "Testing block size  = $bs"
        dd if=/var/tmp/infile of=/var/tmp/outfile bs=$bs
        echo ""
done
rm /var/tmp/infile /var/tmp/outfile
