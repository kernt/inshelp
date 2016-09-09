#!/bin/bash
#            
# Script-Name	 : base-install.sh
# Version	     : 0.01
# Autor		     : Tobias Kern
# Datum		     : $DATE
# Lizenz	     : GPLv3
# Depends      :
# Use          :       
# 
# Example:
#
# Description:
###########################################################################################
#########                            ERROR Codes                          #################
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

##################################################################################################
########## Bach environmentvaribles                                                           ####
##################################################################################################
# Posision from function to script
POSTOFONCA="*"

# Posision from function to script
POSTOFONCONCE="@"

# Options by execute bash
BACHEXECOP="-"

# Exit state from last command
STATELASTCOMMAND="?"

ROOTID=0
SKRIPTNAME=$@

# Executable for Root only 

if [ $(id -u) != 0 ]; then
    echo "Das Script kann nur als Benutzer Root Ausgefuehrt werden!"
    sleep 2
    exit 1
fi

####################################################################################################
#  System functions                                                                             ####
####################################################################################################

####### Add Configurations ########
FILEOUT=$1
TXT=$2

cattext() {
cat > ${FILEOUT} << EOF
${TXT}
EOF
}


INSTALLER=""


# check is command existing ? 
command -v $1 ; echo "$?" 
