#!/bin/bash
#
# Script-Name : $@.sh
# Version : 0.01
# Autor : Tobias Kern
# Datum : $DATE
# Lizenz : GPLv3
# Depends :
# Use :
#
# Example: opsi_ins.sh $#DOMAIN $TESTPW
#
# Sources:
# http://download.uib.de/opsi_stable/doc/opsi-getting-started-stable-de.pdf
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
# simple help funktion,  in this file because this function is only for the script itself
function genpw {
echo "$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 18 | head -1)"
}

function genpw {
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 18 | head -1
}

function onlyroot {
if [ $(id -u) != 0 ]; then
    echo "Script is only for root user! Ask your Administrator"
    exit 1
fi
}

#function md5put {
#md5sum $0 >>  ./md5check-opsi.sum
#}

#function md5get {
#md5sum  << ./md5check-opsi.sum 
#}

function opsinstall {
aptitude update
aptitude safe-upgrade
aptitude remove tftpd
update-inetd --remove tftpd
aptitude -y install opsi-atftpd
aptitude -y install opsi-depotserver
aptitude -y install opsi-configed
}

function opsiconfig {
opsi-setup --auto-configure-samba
opsi-setup --configure-mysql
}

function opsiconfupdate {
opsi-setup --init-current-config
opsi-setup --set-rights
service opsiconfd restart
service opsipxeconfd restart
}

function opsidispatc {
echo "" >> /etc/opsi/backendManager/dispatch.conf
}

function jreinstall {
aptitude update
aptitude -y install openjdk-7-jre icedtea-7-plugin
}

#funktion md5vlalidsh {
## 
#md5putresult=md5get
#if [ ! $md5putresult = 0  ]
# echo "Script overwirte detected please check your script!!!"
#exit 1
#}
