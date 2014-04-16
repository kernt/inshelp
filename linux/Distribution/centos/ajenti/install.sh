#!/usr/bin/env bash
#
# Script-Name : install.sh
# Version : 0.0.1
# Autor : Tobias Kern
# Datum : 16-04-2014
# Lizenz : GPLv3
# Depends : wget
# Use : execute it
#
# Description:
###########################################################################################
## Some Info and so one.
##
###########################################################################################

# fast install
#wget -O- https://raw.github.com/Eugeny/ajenti/master/scripts/install-rhel.sh | sh


#Manual install
#Ajenti requires EPEL repositories: http://fedoraproject.org/wiki/EPEL

#Add repository key:

wget http://repo.ajenti.org/ajenti-repo-1.0-1.noarch.rpm
rpm -i ajenti-repo-1.0-1.noarch.rpm

#Install the package:

yum install ajenti


#Start the service:

service ajenti restart


#Package does not match intended download?

yum clean metadata
