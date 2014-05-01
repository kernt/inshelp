#!/bin/sh
# 
# ubuntu-nfs-server-v01.sh (25 March 2014)
# GeekPeek.Net scripts - Install and configure NFS Server on Ubuntu Server 12.04
#
# INFO: This script was created and tested on fresh Ubuntu Server 12.04 installation. Script installs required packages
# and adds desired entrie to /etc/exports file. It restarts NFS service and shows available NFS mount points.
#
# CODE:
/usr/bin/apt-get update
/usr/bin/apt-get install rpcbind nfs-kernel-server -y
/bin/echo ""
/bin/echo "Please enter the directory you want to export via NFS! (example: /nfs)"
read exportdir
/bin/echo ""
/bin/echo "Please enter the clients you want to export NFS dir to - you can list whole network with mask if desired! (example single IP: 192.168.1.214, example whole network: 192.168.1.0/24)"
read clientlist
/bin/echo "$exportdir $clientlist(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
/etc/init.d/nfs-kernel-server restart
/sbin/showmount -e
/bin/echo ""
/bin/echo "NFS Server successfully configured!"
/bin/echo ""
/bin/echo "You are now ready to mount your exported NFS directory on your NFS client!"
/bin/echo "To add additional directories edit /etc/exports file and add a new line!"
