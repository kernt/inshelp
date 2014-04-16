#!/usr/bin/env bash
#
# Script-Name : install.sh
# Version     : 0.0.1
# Autor       : Tobias Kern
# Datum       : 16-04-2014
# Lizenz      : GPLv3
# Depends     : wget 
# Use         : execute it
#
# Description:
###########################################################################################
## Some Info and so one.
##
###########################################################################################

#  fast install
#wget -O- https://raw.github.com/Eugeny/ajenti/master/scripts/install-debian.sh | sh

# normel install
#Add repository key:
wget http://repo.ajenti.org/debian/key -O- | apt-key add -

#Add repository to /etc/apt/sources.list:
echo "deb http://repo.ajenti.org/debian main main debian" >> /etc/apt/sources.list

exit 0
