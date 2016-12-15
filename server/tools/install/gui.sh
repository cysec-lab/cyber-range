#!/bin/sh

FILENAME='/etc/inittab'
sed -i -e 's/id:3:initdefault:/id:5:initdefault:/g' $FILENAME
