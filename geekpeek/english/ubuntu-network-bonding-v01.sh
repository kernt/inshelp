#!/bin/sh
#
# ubuntu-network-bonding-v01.sh (13 March 2014)
# GeekPeek.Net scripts - Install and configure Network Bonding on Ubuntu Server 12.04
#
# INFO: This script was created and tested on fresh Ubuntu Server 12.04 installation.
# The script installs ifenslave package,
# adds bonding module to /etc/modules re-configures networking and adds bond0 device.
# Networking is restarted automatically
# by this script.
#
# CODE:
/bin/echo "Which bond device are you configuring? (bond0, bond1, bond2, ...)"
read BONDNR
/bin/echo "Which mode number are you configuring? (active-backup, balance-xor, broadcast, 802.3ad, balance-tlb, balance-alb)"
read MODENR
/bin/echo "What IP address do you want to assign to $BONDNR? (192.168.1.100)"
read IPADDRNR
/bin/echo "What is the netmask address you want to assign to $BONDNR? (255.255.255.0)"
read NETMASKNR
/bin/echo "What is the gateway address you want to assign to $BONDNR? (192.168.1.1)"
read GATEWAYNR
/bin/echo "List the first network device you want to assign to $BONDNR (eth0, eth1, eth2, ...)"
read NETNR1
/bin/echo "List the second network device you want to assign to $BONDNR (eth0, eth1, eth2, ...)"
read NETNR2
/bin/cp /etc/network/interfaces /etc/network/interfaces.backup
/usr/bin/apt-get update
/usr/bin/apt-get install ifenslave
/etc/init.d/networking stop
/bin/echo "bonding" >> /etc/modules
/bin/sed -i 's/dhcp/manual/g' /etc/network/interfaces
NETCHK1=$(/bin/grep $NETNR1 /etc/network/interfaces)
NETCHK2=$(/bin/grep $NETNR2 /etc/network/interfaces)
if [ -z "$NETCHK1" ]; then
	/bin/echo "Adding $NETNR1 interface to /etc/network/interfaces..."
	/bin/echo "" >> /etc/network/interfaces
	/bin/echo "auto $NETNR1" >> /etc/network/interfaces
	/bin/echo "iface $NETNR1 inet manual" >> /etc/network/interfaces
	/bin/echo "bond-master $BONDNR" >> /etc/network/interfaces
	/bin/echo "bond-primary $NETNR1" >> /etc/network/interfaces
else
	/bin/sed -i "s/iface $NETNR1 inet manual/&\nbond-master $BONDNR/" /etc/network/interfaces
	/bin/sed -i "s/bond-master $BONDNR/&\nbond-primary $NETNR1/" /etc/network/interfaces
fi
if [ -z "$NETCHK2" ]; then
        /bin/echo "Adding $NETNR2 interface to /etc/network/interfaces..."
        /bin/echo "" >> /etc/network/interfaces
        /bin/echo "auto $NETNR2" >> /etc/network/interfaces
        /bin/echo "iface $NETNR2 inet manual" >> /etc/network/interfaces
        /bin/echo "bond-master $BONDNR">> /etc/network/interfaces
else
        /bin/sed -i "s/iface $NETNR2 inet manual/&\nbond-master $BONDNR/" /etc/network/interfaces
fi
/bin/echo "Inserting $BONDNR interface to /etc/network/interfaces..."
/bin/echo "" >> /etc/network/interfaces
/bin/echo "# Bonding interface configuration" >> /etc/network/interfaces
/bin/echo "auto $BONDNR" >> /etc/network/interfaces
/bin/echo "iface $BONDNR inet static" >> /etc/network/interfaces
/bin/echo "address $IPADDRNR" >> /etc/network/interfaces
/bin/echo "netmask $NETMASKNR" >> /etc/network/interfaces
/bin/echo "gateway $GATEWAYNR" >> /etc/network/interfaces
/bin/echo "bond-slaves $NETNR1 $NETNR2" >> /etc/network/interfaces
/bin/echo "bond-miimon 100" >> /etc/network/interfaces
/bin/echo "bond-mode   $MODENR" >> /etc/network/interfaces
/sbin/modprobe bonding
/etc/init.d/networking start
cat /proc/net/bonding/$BONDNR
/bin/echo "Network bonding finished!"
