#!/bin/sh
# 
# install-spacewalk-v01.sh (12 February 2014)
# GeekPeek.Net scripts - Install Spacewalk Management Tool
#
# INFO: This script was created and tested on fresh CentOS 6.5 minimal installation with IPtables and SELinux disabled. 
# You need to have 12GB of free space available at PostgreSQL location for script to work and a working FQDN name resolution.
# This script configures Spacewalk, EPEL and Jpackage repositories and installs Wget, PostgreSQL and Spacewalk and it's 
# dependencies. It runs Spacewalk setup to configure Spacewalk. When the script ends please visit https://hostname.domainname 
# to create Spacewalk Web Administrator user.
#
# CODE:
/bin/echo ""
/bin/echo "Installing wget package..."
/bin/echo ""
/usr/bin/yum install wget -y
/bin/echo ""
/bin/echo "Adding necessary repositories..."
/bin/echo ""
/bin/rpm -Uvh http://yum.spacewalkproject.org/2.0/RHEL/6/x86_64/spacewalk-repo-2.0-3.el6.noarch.rpm
/bin/rpm -Uvh http://mirror.muntinternet.net/pub/epel/6/i386/epel-release-6-8.noarch.rpm
/usr/bin/wget http://www.jpackage.org/jpackage50.repo
/bin/mv jpackage50.repo /etc/yum.repos.d/
/bin/echo ""
/bin/echo "Setting up and installing PostgreSQL database..."
/bin/echo ""
/usr/bin/yum install spacewalk-setup-postgresql -y
/usr/bin/yum install spacewalk-postgresql -y
/bin/echo ""
/bin/echo "Configuring Spacewalk...! Please enter the requested information!"
/bin/echo ""
sleep 1
/usr/bin/spacewalk-setup --disconnected
/bin/echo ""
/bin/echo "Spacewalk configured and installed. Please visit https://hostname.domainname to create Spacewalk Web Administrator user!"
/bin/echo ""
