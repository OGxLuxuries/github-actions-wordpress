#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y wget php-mysqlnd httpd php-fpm php-mysqli mariadb105-server php-json php php-devel
systemctl enable --now mariadb httpd php-fpm

DB_NAME="wordpress"
DB_USER="wordpress"
DB_PASSWORD="$(openssl rand -hex 24)"

mysql -e "CREATE DATABASE ${DB_NAME};"
mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;"

cd /var/www/html
wget -q https://wordpress.org/latest.tar.gz -O latest.tar.gz
tar -xzf latest.tar.gz --strip-components=1

cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/${DB_NAME}/" wp-config.php
sed -i "s/username_here/${DB_USER}/" wp-config.php
sed -i "s/password_here/${DB_PASSWORD}/" wp-config.php
chown -R apache:apache /var/www/html
