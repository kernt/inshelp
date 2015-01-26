#!/bin/bash -x
#
# Example: post_opsi_install.sh $#DOMAIN $TESTPW
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
# simple help funktion , in this file because this function is only for the script itself. All others functions put in opsi_func.sh please.
function usage {
echo "Usage: $SCRIPTNAME [-h] [-v] [-o arg] file ..." >&2
[[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}

aptitude -y install isc-dhcp-server 
aptitude -y install isc-dhcp-server-ldap 

# if [] ; then
# . ./migration/opsi_lic.sh
# fi

# if [] ; then
#. ./migration/opsi_migration.sh
# fi


