#!/usr/bin/env bash

set -ex
sed -i 's/includedir \/etc\/mysql\/conf.d\//includedir \/etc\/mysql\/conf\//g' /etc/mysql/mariadb.cnf
