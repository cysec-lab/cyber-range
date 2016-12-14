#!/bin/sh
# Create DB
mysql -uroot -pcysec.lab < login_db.sql

# Create DB table
mysql -uroot -pcysec.lab login_db < login_users.sql

# Default User
mysql -uroot -pcysec.lab login_db < default_users.sql
