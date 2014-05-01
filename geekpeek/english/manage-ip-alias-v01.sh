#!/bin/sh
# 
# manage-ip-alias-v01.sh (23 October 2013)
# GeekPeek.Net scripts - Manage IP Alias on CentOS 6
#
# INFO: This script was created and tested on fresh CentOS 6.4 minimal installation. You can use this script to create
# IP Alias Network Interfaces on CentOS 6. The script creates a persistent or non-persistent Alias Network Interface.
# If you choose non-persistent Alias Interface no configuration file is created, if you choose persistent Alias Interface, 
# you must enter the IP Address and Netmask information and ifcfg-ethX:Y configuration file is created. All Alias interfaces
# are brought up when created.
#
# CODE:
echo ""
echo "Do you want to configure persistent Alias Interface? (y/n):"
read persistent
echo ""
echo "Please enter the number of the Alias Interface (example: eth0:0, eth0:1, ...):"
read interfacenum
echo ""
interface=$(echo "$interfacenum" |awk -F: '{print$1}')
checkint1=$(/bin/ls -la /etc/sysconfig/network-scripts/ifcfg-$interface 2> /dev/null)
checkint2=$(/bin/ls -la /etc/sysconfig/network-scripts/ifcfg-$interfacenum 2> /dev/null)
if [ -z "$checkint1" ]; then
	echo "No Physical Interface $interfce configuration file found! Exiting...!"
	echo ""
	exit 3;
else
if [ -n "$checkint2" ]; then
        echo "Alias Interface $interfacenum configuration file already exists! Exiting...!"
	echo ""
        exit 3;
else
case $persistent in
	y)
		echo "Please note that the Alias Interface IP Address should be in the same subnet as Physical Network Interface below!"
		echo ""
		echo "Please enter the IP Address for the Alias Interface $interfacenum. (example: 192.168.1.101):"
		read ipaddr1
		echo ""
		echo "Please enter the Netmask for the Alias Interface. (example: 255.255.255.0):"
		read netmask
		echo ""
		echo "....generating Alias Interface configuration file..."
		echo ""
		echo "DEVICE=$interfacenum" >> /etc/sysconfig/network-scripts/ifcfg-$interfacenum
		echo "TYPE=Ethernet" >> /etc/sysconfig/network-scripts/ifcfg-$interfacenum
		echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-$interfacenum
		echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-$interfacenum
		echo "IPADDR=$ipaddr1" >> /etc/sysconfig/network-scripts/ifcfg-$interfacenum
		echo "NETMASK=$netmask" >> /etc/sysconfig/network-scripts/ifcfg-$interfacenum
		/sbin/ifup $interfacenum
		/sbin/ifconfig
		;;
	n)
		echo "Please enter the IP Address for the Alias Interface $interfacenum. (example: 192.168.1.101):"
		read ipaddr2
		echo ""
		/sbin/ifconfig $interfacenum $ipaddr2 up
		echo "Alias Interface started:"
		echo ""
		/sbin/ifconfig
		;;
	*)
		echo "Unknown choice! Exiting..."
		;;
esac
fi
fi
