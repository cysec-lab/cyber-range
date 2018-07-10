#!/bin/bash
#
#create a file to work with
#
echo "creating a file to work with"
dd if=/dev/zero of=/rpool/tmp_infile count=11750000

for bs in  16M 32M 64M 128M 256M 512M 1G 2G 4G

do
        echo "---------------------------------------"
        echo "Testing block size  = $bs"
        dd if=/rpool/tmp_infile of=/rpool/tmp_outfile bs=$bs
        echo ""
done
rm /rpool/tmp_infile /rpool/tmp_outfile
