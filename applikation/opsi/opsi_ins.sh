#!/bin/bash
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
EXIT_SUCCESS="0"
# exit code I/O failure
EXIT_FAILURE="1"
# exit code error if known
EXIT_ERROR="2"
# unknown ERROR
EXIT_BUG="10"

# simple help funktion , in this file because this function is only for the script itself. All others functions put in opsi_func.sh please.
function usage {
        echo "Usage: $SCRIPTNAME [-h] [-v] [-o arg] file ..." >&2
                [[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}

# Report opsi install
#touch /root/opsi.installed

. ./pre_opsi_ins.sh   # execute pre_opsi_ins.sh for por pre depend requested packages and configurations
. ./opsi_func.sh      # execute opsi_ins.sh
# make shure the login user is ROOT
onlyroot

# do install opsi services
#if [ !  $(ls -A /etc/opsi/) ]; then
opsinstall
#else
#    echo "Error: runs more than once a time!"
#    echo "This script is only for a initial opsi Installation!"
#    echo "because this error this script will be exit now"
#    sleep 4
#    exit 1
#fi

# function . Do opsi initial configuration, use only for your first installation !
# test of files time its a well idea
opsiconfig

# function. Update your opsi configuraton files only for first installation
opsiconfupdate

# Show your Java version
JREVERSION="$(java -version)"
opsi-admin -d task setPcpatchPassword
echo "You have JAVA Version: $JREVERSION"
echo "user update-alternatives --config java if you have any error."
sleep 3

# Install initial Products from UIB GmbH
if [ !  $(ls -A /var/lib/opsi/depot) ]; then 
. ./opsi-produc-initial.sh
else
    echo "Error: runs more than once a time!"
    echo "This script is only for a initial opsi Installation!"
    echo "because this error this script will be exit now"
    sleep 4
    exit 1
fi

exit 0
