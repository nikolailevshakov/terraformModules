#!/bin/bash


apt update -y
apt -y install apache2
cd /var/www/html
chmod 644 index.html
echo "<h1>IP: $(curl http://169.254.169.254/latest/meta-data/local-ipv4) </h1>" > index.html


