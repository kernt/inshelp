#!/usr/bin/env bash
#
# Script-Name : ins_ajenti.sh
# Version     : $VERSION
# Autor       : Tobias Kern
# Date        : Mo 10 Mär 2014 11:58:58 CET
# Lizenz      : GPLv3
# Depends     :
# Use         :
#
# Description:
###########################################################################################
## Tested with Debian GNU/Linux 7.4 (wheezy)
##
###########################################################################################

asrootonly() {
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
  fi
}

asrootonly

# Manual install
# Ajenti requires Debian 6 or later. Debian 5 might work with Python 2.6 installed.
# Debian Squeeze requires squeeze-backports repository: http://backports.debian.org/Instructions/

#Add repository key:
wget http://repo.ajenti.org/debian/key -O- | apt-key add -

#Add repository to /etc/apt/sources.list:
echo "deb http://repo.ajenti.org/debian main main debian" >> /etc/apt/sources.list

#Install the package:
apt-get update && apt-get install ajenti

#Start the service:
service ajenti restart

#The panel will be available on HTTPS port 8000. The default username is root, and the password is admin

exit 0
