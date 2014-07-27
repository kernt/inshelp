#!/bin/bash
#
# Script-Name : ins_tmate.sh
# Version     : 0.01
# Autor       : Tobias Kern
# Datum       : 27.07.2014
# Lizenz      : GPLv3
# Depends     : git, apt-get
# Use         :
#
# Example:
#
# Description: tested on Debian linux 
###########################################################################################
## find the deb OS based version.
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

GETRELEASE=$(debian-distro-info --stable)



