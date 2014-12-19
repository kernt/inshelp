#!/bin/bash
#
# Script-Name : newtokenssl.sh
# Version : 0.01
# Autor : Tobias Kern
# Datum : 10.03.2003
# Lizenz : GPLv3
# Depends : openssl
# Use :
#
# Example:
#
# Description:
###########################################################################################
## Some Info and so one.
##
###########################################################################################
#!/bin/sh
newtoken() {
	openssl rand -hex 10;
	}

#for j=0 ; <=10 ; j++
#do
#	echo newtoken
#done
echo newtoken
exit 0
