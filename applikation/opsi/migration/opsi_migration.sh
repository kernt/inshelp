#!/bin/bash
#
# Example: opsi_migration.sh $#DOMAIN $TESTPW
#
# Sources:
# http://download.uib.de/opsi_stable/doc/opsi-getting-started-stable-de.pdf
# http://download.uib.de/opsi_stable/doc/html/en/opsi-getting-started/opsi-getting-started.html#opsi-getting-started-installation-base-centos
# 
# Description:
###########################################################################################
## 
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

. ./opsi_func.sh     # execute opsi_ins.sh 

# if [ -s  ] ; then
# fi 

# if [ -d  ] ; then
# fi 

# just a concept 
# for $file *.migrate
# do cp "$file"
#    mv $file $file.conf 
#    diff $file.migrate $file.conf >> $file.patch


exit 0
