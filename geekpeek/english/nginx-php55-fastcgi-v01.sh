#!/bin/sh
# 
# nginx-php55-fastcgi-v01.sh (23 October 2013)
# GeekPeeK.Net Scripts - Install Nginx, PHP 5.5 and FastCGI on CentOS 6
#
# INFO: This script was created and tested on fresh CentOS 6.4 minimal installation. This script installs EPEL and Remi
# Repositories and creates Nginx repository file for Nginx installation. It installs Nginx, PHP 5.5 and FastCGI. It creates 
# a dummy testsite.com configuration - /srv/www/testsite directory where public_html and logs dir is located and 
# /etc/nginx/sites-available/testsite virtualhost file. It creates a PHP Info index.php file at location 
# /srv/www/testsite/public_html and starts Nginx and FastCGI. After the installation is completed, you can check the
# configuration PHP info file by opening testsite.com in your browser.
#
# CODE:
basearch=$(uname -i)
/bin/echo ""
/bin/echo "Installing EPEL and Remi CentOS 6 repositories..."
/bin/rpm -ivh http://ftp.uninett.no/linux/epel/6/i386/epel-release-6-8.noarch.rpm 
/bin/rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
/bin/echo ""
/bin/echo "Creating NGINX repository file..."
/bin/echo "[nginx]" >> /etc/yum.repos.d/nginx.repo
/bin/echo "name=nginx repo" >> /etc/yum.repos.d/nginx.repo
/bin/echo "baseurl=http://nginx.org/packages/centos/6/$basearch/" >> /etc/yum.repos.d/nginx.repo
/bin/echo "gpgcheck=0" >> /etc/yum.repos.d/nginx.repo
/bin/echo "enabled=1" >> /etc/yum.repos.d/nginx.repo
/bin/echo ""
/bin/echo "Stopping HTTPD, disabling autostart on boot..."
/etc/init.d/httpd stop  > /dev/null 2>&1
chkconfig httpd off  > /dev/null 2>&1
/bin/echo "Installing NGINX, PHP 5.5 and FastCGI..."
/usr/bin/yum --enablerepo=remi,remi-php55 install nginx php-common php-fpm php-mysqlnd -y
/bin/echo "Enabling NGINX and FastCGI autostart on boot..."
chkconfig nginx on
chkconfig php-fpm on
/bin/echo "Creating test Website DocumentRoot at location /srv/www/testsite/public_html."
/bin/mkdir -p /srv/www/testsite/public_html
/bin/echo "Creating test Website log directory at location /srv/www/testsite/logs."
/bin/mkdir -p /srv/www/testsite/logs
/bin/mkdir /etc/nginx/sites-available
/bin/mkdir /etc/nginx/sites-enabled
/bin/mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
/bin/awk '/include \/etc\/nginx\/conf.d\/\*.conf;/{print;print "    include /etc/nginx/sites-enabled/*;";next}1' /etc/nginx/nginx.conf.old >> /etc/nginx/nginx.conf
/bin/echo "Creating test Website virtualhost file..."
/bin/echo "server {" >> /etc/nginx/sites-available/testsite
/bin/echo "    server_name testsite.com;" >> /etc/nginx/sites-available/testsite
/bin/echo "    access_log /srv/www/testsite/logs/access.log;" >> /etc/nginx/sites-available/testsite
/bin/echo "    error_log /srv/www/testsite/logs/error.log;" >> /etc/nginx/sites-available/testsite
/bin/echo "    root /srv/www/testsite/public_html;" >> /etc/nginx/sites-available/testsite
/bin/echo "" >> /etc/nginx/sites-available/testsite
/bin/echo "    location / {" >> /etc/nginx/sites-available/testsite
/bin/echo "        index index.html index.htm index.php;" >> /etc/nginx/sites-available/testsite
/bin/echo "    }" >> /etc/nginx/sites-available/testsite
/bin/echo "" >> /etc/nginx/sites-available/testsite
/bin/echo "    location ~ \.php$ {" >> /etc/nginx/sites-available/testsite
/bin/echo "	   try_files \$uri =404;" >> /etc/nginx/sites-available/testsite	
/bin/echo "        include /etc/nginx/fastcgi_params;" >> /etc/nginx/sites-available/testsite
/bin/echo "        fastcgi_pass  127.0.0.1:9000;" >> /etc/nginx/sites-available/testsite
/bin/echo "        fastcgi_index index.php;" >> /etc/nginx/sites-available/testsite
/bin/echo "        fastcgi_param SCRIPT_FILENAME /srv/www/testsite/public_html\$fastcgi_script_name;" >> /etc/nginx/sites-available/testsite
/bin/echo "    }" >> /etc/nginx/sites-available/testsite
/bin/echo "}" >> /etc/nginx/sites-available/testsite
/bin/echo "Creating a virtualhost file link in /etc/nginx/sites-enabled..."
/bin/ln -s /etc/nginx/sites-available/testsite /etc/nginx/sites-enabled/testsite
/bin/echo ""
/bin/echo "Crerating PHP info file in testsite DocumentRoot..."
/bin/echo "<?php" >> /srv/www/testsite/public_html/index.php
/bin/echo " phpinfo();" >> /srv/www/testsite/public_html/index.php
/bin/echo "?>" >> /srv/www/testsite/public_html/index.php
/bin/chown apache:apache -R /srv/www/
/bin/echo ""
/bin/echo "Starting NGINX and FastCGI..."
/etc/init.d/nginx start
/etc/init.d/php-fpm start
