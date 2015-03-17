#!/bin/bash
#
# Script-Name : chroot-bind9-debian7.sh
# Version     : 0.01
# Autor       : Tobias Kern
# Datum       : 17.03.2015
# Lizenz      : GPLv3
# Depends     :
# Use         :
#
# Example:
#
# Description:
###########################################################################################
## Some Info and so one.
##
###########################################################################################
# Name of your script.
SCRIPTNAME=$(basename $0.sh)
# exit code without any error
EXIT_SUCCESS=0
# exit code I/O failure
EXIT_FAILURE=1
# exit code error if known
EXIT_ERROR=2
# unknown ERROR
EXIT_BUG=10

# Install Bind9 and utils
echo "Install Bind9 with utils"
sleep 2
apt-get install bind9 bind9utils
#
# stop service
echo "Stop service Bind9"

service bind9 stop

# not wirking ??
sed -i 's/RESOLVCONF=no/RESOLVCONF=yes/'  bind9
sed -i 's/OPTIONS="-u bind"/OPTIONS="-u bind -t /var/named"/' bind9 # not working !!!


mkdir -p /var/named/{etc,dev}
mkdir -p /var/named/var/cache/bind
mkdir -p /var/named/var/run/bind/run

mv /etc/bind /var/named/etc

ln -s /var/named/etc/bind /etc/bind

mknod /var/named/dev/null c 1 3
mknod /var/named/dev/random c 1 8

chmod 666 /var/named/dev/{null,random}
chown -R bind:bind /var/named/var/*
chown -R bind:bind /var/named/etc/bind

service bind9 restart
