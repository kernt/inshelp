#!/bin/bash
# Shell script to check A record for given domain or hostname on all Nameservers
# -------------------------------------------------------------------------
# Copyright (c) 2002 nixCraft project <http://cyberciti.biz/fb/>
# This script is licensed under GNU GPL version 2.0 or above
# -------------------------------------------------------------------------
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# -------------------------------------------------------------------------
# How do I use this script?
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ./script nixcraft.net 3 cyberciti.biz ns
# where,
# * nixcraft.net - nameserver domain name
# * 3 - total number of nameserver
# * cyberciti.biz - Domain name to check for A record
# * ns - nameserver domain prefix, so ns becomes ns1.nixcraft.net,ns2.nixcraft.net,ns3.nixcraft.net
# It will check cyberciti.biz domain on all 3 nameservers i.e. ns{1,2,3}.nixcraft.net
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Note: Only tested on GNU/Linux but should work under BSD / UNIX like oses.
# Last updated on: Jul-30-2008: Added failsafe and nameserver test.
#-----------------------------------------------------------------------
DOMAIN="$1" # nameserver domain
MAX="$2" # query ns
AREC="$3" # domain or hostname to check against given nameserver
NS="$4"
     
# make sure we get args
if [ ! $# -ge 3 ]
  then
    echo "$(basename $0) nameserver-domain number-of-nameservers domain-name-to-check nameserver-domain-prefix"
    echo "Example: Check domain viveks.org on all 3 nameservers ns1.nixcraft.net, ns2.nixcraft.net, ns2.nixcraft.net, enter:"
    echo "$(basename $0) nixcraft.net 3 viveks.org"
  exit 1
fi
     
# shell array to hold all A records
IPArray[0]=0
     
# failsafe
[ "$4" == "" ] && NS="ns"
     
  # note seq may not be available on other UNIX like oses
  for n in $(seq 1 ${MAX})
    do
    # build nameserver name
     thisNs="${NS}${n}.${DOMAIN}"
    # make sure nameserver exits
     host $thisNs | grep "NXDOMAIN" >/dev/null
    if [ $? -eq 0 ]
    then
    echo "Nameserver $thisNs does not exits..."
    exit 2
    fi
    # get output
    out=$(host $AREC $thisNs | grep address)
    # get A record
    IPArray[$n]=$(echo $out | awk '{print $4}')
    [ "$out" != "" ] && echo "${out} [$thisNs]"
    done
     
    firstIp="$(echo ${IPArray[1]})"
    isARecSame=0
     
    # use for loop to see all A records
    for (( i=1; i<=$MAX; i++ ));
    do
    [ "$firstIp" != "${IPArray[$i]}" ] && isARecSame=1 || :
    done
     
    [ $isARecSame -eq 1 ] && echo "Warning: A record is not matching on all nameserver(s)" || :

#How do I use this script?
#
#Find out A record for domain viveks.org on all 3 nameservers:
#$ ./176.sh nixcraft.net 3 viveks.org
#Sample output:
#
#viveks.org has address 74.86.49.130 [ns1.nixcraft.net]
#viveks.org has address 74.86.49.130 [ns2.nixcraft.net]
#viveks.org has address 74.86.49.130 [ns3.nixcraft.net]
