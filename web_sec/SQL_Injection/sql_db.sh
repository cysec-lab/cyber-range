#!/bin/sh
# Create DB
mysql -uroot -pcysec.lab < sql_db.sql

# Create DB table
mysql -uroot -pcysec.lab sql_db < users.sql

# First message
mysql -uroot -pcysec.lab sql_db < first_user.sql
