#!/usr/bin/env coffee

> @3-/write
  path > join
  ./conf > ROOT

{
  MYSQL_PWD
  MYSQL_DB
  MYSQL_USER
} = process.env

sql = """
CREATE DATABASE `#{MYSQL_DB}` CHARACTER SET binary;
"""

if MYSQL_USER != "root"
  sql += """
CREATE USER '#{MYSQL_USER}'@'%' IDENTIFIED BY '#{MYSQL_PWD}';
GRANT ALL PRIVILEGES ON #{MYSQL_DB}.* TO '#{MYSQL_USER}'@'%';
"""

write(
  join ROOT, "conf/mariadb/init/init.sql"
  sql
)
