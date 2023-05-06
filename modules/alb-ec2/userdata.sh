#!/bin/bash


apt update -y
apt -y install httpd
systemctl start httpd
cd var/www/html
echo '<!DOCTYPE html>' > index.html
echo '<html>' >> index.html
echo '<head>' >> index.html
echo '<title>Level It Up</title>' >> index.html
echo '<meta charset="UTF-8">' >> index.html
echo '</head>' >> index.html
echo '<body>' >> index.html
echo "<h1>IP: $(curl http://169.254.169.254/latest/meta-data/local-ipv4) </h1>" >> index.html
echo '</body>' >> index.html
echo '</html>' >> index.html

