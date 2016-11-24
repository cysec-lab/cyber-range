#!/bin/sh
# Create DB
mysql -uroot -pcysec.lab < stored_db.sql

# Create DB table
mysql -uroot -pcysec.lab stored_db < guestbook.sql

# First message
mysql -uroot -pcysec.lab stored_db < first_comment.sql
