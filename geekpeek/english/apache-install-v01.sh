#!/bin/sh
# 
# apache-install-v01.sh (19 July 2013)
# GeekPeek.Net scripts - Install Apache Server on CentOS 6
#
# INFO: This script was created and tested on fresh CentOS 6.4 minimal installation. The script installs 
# httpd package and dependencies. It starts the Apache daemon (httpd) and enables Apache to start at boot time.
#
# CODE:
/usr/bin/yum install httpd -y
/sbin/chkconfig httpd on
service httpd start
