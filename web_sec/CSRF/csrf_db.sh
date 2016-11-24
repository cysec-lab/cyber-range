#!/bin/sh
# Create DB
mysql -uroot -pcysec.lab < csrf_db.sql

# Create DB table
mysql -uroot -pcysec.lab csrf_db < users.sql

# First message
mysql -uroot -pcysec.lab csrf_db < first_user.sql
