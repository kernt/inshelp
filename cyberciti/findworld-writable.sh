#!/bin/bash
# Shell script to find all world-writable files and directories on Linux or
# FreeBSD system
#
# TIP:
# Set 'umask 002' so that new files created will not be world-writable
# And use command 'chmod o-w filename' to disable world-wriable file bit
#
# Copyright (c) 2005 nixCraft project
# This script is licensed under GNU GPL version 2.0 or above
# For more info, please visit:
# http://cyberciti.biz/shell_scripting/bmsinstall.php
# -------------------------------------------------------------------------
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# -------------------------------------------------------------------------
#SPATH="/usr/local/etc/bashmonscripts"
#INITBMS="$SPATH/defaults.conf"
#[ ! -f $INITBMS ] && exit 1 || . $INITBMS
     
[ $# -eq 1 ] && : || die "Usage: $($BASENAME $0) directory" 1
     
DIRNAME="$1"
$FIND $DIRNAME -xdev -perm +o=w ! \( -type d -perm +o=t \) ! -type l -print
