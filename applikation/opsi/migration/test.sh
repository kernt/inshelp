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
EXIT_SUCCESS=0
# exit code I/O failure
EXIT_FAILURE=1
# exit code error if known
EXIT_ERROR=2
# unknown ERROR
EXIT_BUG=10

fbname=$(basename "$1".txt)

#. ../opsi_func.sh     # execute opsi_ins.sh

if [ -f modules ] ; then
 cp ./modules /etc/opsi/
 echo "Copy modules file to /etc/opsi/"
if
