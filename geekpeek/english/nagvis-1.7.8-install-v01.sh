#!/bin/sh
# 
# nagvis-1.7.8-install-v01.sh (28 May 2013)
# GeekPeek.Net scripts - Install NagVis 1.7.8
#
# INFO: This script was created and tested on fresh CentOS 6.4 minimal installation. The script installs 
# NagVis 1.7.8 and dependencies. It starts NagVis configuration wizzard and restarts Apache.
#
# Requirements: Nagios, MK Livestatus
#
# Preferred: Works best with nagios-core-3.5.0-install and mk-livestatus-install script from GeekPeek.Net
#
/usr/bin/yum install php-gd php-mbstring php-pdo graphviz graphviz-graphs perl-GraphViz graphviz-doc rsync -y
/usr/bin/wget http://downloads.sourceforge.net/project/nagvis/NagVis%201.7/nagvis-1.7.8.tar.gz
/bin/tar -xvzf nagvis-1.7.8.tar.gz
cd nagvis-1.7.8
./install.sh
/etc/init.d/httpd restart
