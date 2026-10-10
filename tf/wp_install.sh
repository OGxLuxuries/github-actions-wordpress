#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y httpd php php-mysqlnd mariadb105
systemctl enable --now httpd

cd /var/www/html
curl -fsSLo latest.tar.gz https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz --strip-components=1
chown -R apache:apache /var/www/html
