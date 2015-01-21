#!/bin/bash
#
# Script-Name : pre_opsi_ins.sh
# Version : 0.01
# Autor : Tobias Kern
# Datum : $DATE
# Lizenz : GPLv3
# Depends :
# Use :
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
# Variable for optionsswitch
#OPTFILE=""
fbname=$(basename "$1".txt)
# simple help funktion
#function usage {
#echo "Usage: $SCRIPTNAME [-h] [-v] [-o arg] file ..." >&2
#[[ $# -eq 1 ]] && exit $1 || exit

# Variables
FQDNAME="getent hosts $(hostname -f)"

# Make schure you use the rigt FQDN befor you install OPSI
echo "Your FQDN is $FQDNAME"

aptitude -y install wget lsof host python-mechanize p7zip-full cabextract openbsd-inetd pigz
aptitude -y install samba samba-common smbclient cifs-utils samba-doc
aptitude -y install mysql-server 
aptitude -y install openjdk-7-jre

#if  [] 
touch /etc/apt/sources.list.d/opsi.list

echo  "
deb http://download.opensuse.org/repositories/home:/uibmz:/opsi:/opsi40/Debian_7.0 ./
" >> /etc/apt/sources.list.d/opsi.list

echo "add repositorie gpg key for opsi "
wget -O - http://download.opensuse.org/repositories/home:/uibmz:/opsi:/opsi40/Debian_7.0/Release.key | apt-key add -
