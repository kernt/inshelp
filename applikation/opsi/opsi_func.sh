#!/bin/bash
#
# Script-Name : $@.sh
# Version     : 0.01
# Autor       : Tobias Kern
# Datum       : Di 03 Feb 2015 15:01:55 CET
# Lizenz      : GPLv3
# Depends     : 
# Use         : 
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
# simple help funktion, in this file because this function is only for the script itself.

machine=$(uname -m)
os=$(uname -s)

# Platform detection
function osdetect {
if test -f "/etc/lsb-release" && grep -q DISTRIB_ID /etc/lsb-release; then
  platform=$(grep DISTRIB_ID /etc/lsb-release | cut -d "=" -f 2 | tr '[A-Z]' '[a-z]')
  #platform_version=`grep DISTRIB_RELEASE /etc/lsb-release | cut -d "=" -f 2`
elif test -f "/etc/debian_version"; then
  platform="debian"
  #platform_version=`cat /etc/debian_version`
elif test -f "/etc/redhat-release"; then
  platform=$(sed 's/^\(.\+\) release.*/\1/' /etc/redhat-release | tr '[A-Z]' '[a-z]')
  #platform_version=`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release`
  return $platform
}

# Check whether a command exists - returns 0 if it does, 1 if it does not
function exists {
  if command -v $1 >/dev/null 2>&1
  then
    return 0
  else
    return 1
  fi
}


function genpw {
echo "$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 18 | head -1)"
}

# genarate pasword with 16 characters
function genpw {
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 18 | head -1
}

# execute only if user ROOT.
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

# opsi base installtion is only for first installation
function opsinstall {
aptitude update
aptitude safe-upgrade
aptitude remove tftpd
update-inetd --remove tftpd
aptitude -y install opsi-atftpd
aptitude -y install opsi-depotserver
aptitude -y install opsi-configed
}

# update your opsi configuraton files only for first installation. 
function opsiconfig {
opsi-setup --auto-configure-samba
opsi-setup --configure-mysql
}

# update your customized configurations
function opsiconfupdate {
opsi-setup --init-current-config
opsi-setup --set-rights
service opsiconfd restart
service opsipxeconfd restart
}
# add your licenses
function opsidispatc {
echo "" >> /etc/opsi/backendManager/dispatch.conf
}


function jreinstall {
aptitude -y install openjdk-7-jre icedtea-7-plugin
}

set_hostname () {
i=0
while [ $i -eq 0 ]; do
        if [ "$forcehostname" = "" ]; then
        printf "Please enter a fully qualified hostname (for example, host.example.com): "
        read line
                else
                logger_info "Setting hostname to $forcehostname"
                line=$forcehostname
        fi
        
        if ! is_fully_qualified $line; then
        logger_info "Hostname $line is not fully qualified."
        else
        hostname $line
        detect_ip
        
        if grep $address /etc/hosts; then
        logger_info "Entry for IP $address exists in /etc/hosts."
        logger_info "Updating with new hostname."
        shortname=`echo $line | cut -d"." -f1`
        sed -i "s/^$address\([\s\t]+\).*$/$address\1$line\t$shortname/" /etc/hosts
                else
                logger_info "Adding new entry for hostname $line on $address to /etc/hosts."
                printf "$address\t$line\t$shortname\n" >> /etc/hosts
        fi
        i=1
        fi
done
}

is_fully_qualified () {
case $1 in
localhost.localdomain)
logger_info "Hostname cannot be localhost.localdomain."
return 1
;;
*.localdomain)
logger_info "Hostname cannot be *.localdomain."
return 1
;;
*.*)
logger_info "Hostname OK: fully qualified as $1"
return 0
;;
esac
logger_info "Hostname $name is not fully qualified."
return 1
}

# download()
# Use $download to download the provided filename or exit with an error.
download() {
if $download $1
then
success "Download of $1"
return $?
else
fatal "Failed to download $1."
fi
}

#funktion md5vlalidsh {
## 
#md5putresult=md5get
#if [ ! $md5putresult = 0  ]
# echo "Script overwirte detected please check your script!!!"
#exit 1
#}
