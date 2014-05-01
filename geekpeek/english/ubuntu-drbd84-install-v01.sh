#!/bin/sh
# 
# ubuntu-drbd84-install-v01.sh (13 March 2014)
# GeekPeek.Net scripts - Install and configure DRBD 8.4 on Ubuntu Server 12.04
#
# INFO: This script was created and tested on fresh Ubuntu Server 12.04 installation. The script python-software-properties
# and adds personal repository ppa:icamargo/drbd. It installs drbd8-utils package and loads drbd module. It configures SSH key
# authentication for root between the two machines and configured DRBD resource. It creates DRBD metadata and filesystem on 
# DRBD device. It starts DRBD service and ends up with Secondary/Secondary DRBD status. To end you need to manually set primary
# DRBD node with "drbdadm primary resourcename".
#
# CODE:
echo "For this script to work as expected, you need to enable root SSH access and set root password on the second machine!!"
echo "VERY IMPORTANT!! Is SSH root access enabled on the second machine? Please re-check if not sure! (y/n)"
read rootssh
case $rootssh in
	y)
		echo "Please enter the second machine IP address."
		read ipaddr2
		echo "Generating SSH key - press Enter a couple of times..."
		/usr/bin/ssh-keygen
		echo "Copying SSH key to the second machine..."
		echo "Please enter root password for the second machine."
		/usr/bin/ssh-copy-id root@$ipaddr2
		echo "Succesfully set up SSH with key authentication...continuing with package installation on both machines..."
		;;
	n)
		echo "Root access must be enabled on the second machine...exiting!"
		exit 1
		;;
esac
/usr/bin/apt-get install python-software-properties -y
/usr/bin/ssh root@$ipaddr2 /usr/bin/apt-get install python-software-properties -y
/usr/bin/add-apt-repository ppa:icamargo/drbd -y
/usr/bin/ssh root@$ipaddr2 /usr/bin/add-apt-repository ppa:icamargo/drbd -y
/usr/bin/apt-get update
/usr/bin/ssh root@$ipaddr2 /usr/bin/apt-get update
/usr/bin/apt-get install drbd8-utils -y
/usr/bin/ssh root@$ipaddr2 /usr/bin/apt-get install drbd8-utils -y
/sbin/modprobe drbd
/usr/bin/ssh root@$ipaddr2 /sbin/modprobe drbd
echo "Creating DRBD resource config file - need some additional INFO."
echo "..."
echo "Which DRBD device is this on your machines - if this is your first enter drbd0, if second enter drbd1, and so on... (example: drbd0)"
read drbdnum
echo "If you have more than one DRBD device you need to change the port for DRBD communication - leave empty for default! (example: 7790)"
read drbdport
echo "Enter hostname of your current machine - if incorrect DRBD will not start! Please re-check! (example: foo1):"
read fqdn1
echo "Enter current machine IP address (example: 192.168.1.100):"
read ipaddr1
echo "Enter current machine disk intended for DRBD (example: /dev/sdb):"
read disk1
echo "Enter FQDN of your second machine - if incorrect DRBD will not start! Please re-check! (example: foo2):"
read fqdn2
echo "Enter second machine IP address (example: 192.168.1.101):"
read ipaddr2
echo "Enter second machine disk intended for DRBD (example: /dev/sdb):"
read disk2
echo "Creating DRBD configuration file..."
echo "resource disk$drbdnum" >> /etc/drbd.d/disk$drbdnum.res
echo "{" >> /etc/drbd.d/disk$drbdnum.res
echo "     startup {" >> /etc/drbd.d/disk$drbdnum.res
echo "          wfc-timeout 30;" >> /etc/drbd.d/disk$drbdnum.res
echo "          outdated-wfc-timeout 20;" >> /etc/drbd.d/disk$drbdnum.res
echo "          degr-wfc-timeout 30;" >> /etc/drbd.d/disk$drbdnum.res
echo "     }" >> /etc/drbd.d/disk$drbdnum.res
echo "     net {" >> /etc/drbd.d/disk$drbdnum.res
echo "          cram-hmac-alg sha1;" >> /etc/drbd.d/disk$drbdnum.res
echo "          shared-secret "sync_disk";" >> /etc/drbd.d/disk$drbdnum.res
echo "     }" >> /etc/drbd.d/disk$drbdnum.res
echo "     syncer {" >> /etc/drbd.d/disk$drbdnum.res
echo "          rate 100M;" >> /etc/drbd.d/disk$drbdnum.res
echo "          verify-alg sha1;" >> /etc/drbd.d/disk$drbdnum.res
echo "     }" >> /etc/drbd.d/disk$drbdnum.res
echo "	   on $fqdn1 {" >> /etc/drbd.d/disk$drbdnum.res
echo "          device $drbdnum;" >> /etc/drbd.d/disk$drbdnum.res
echo "          disk $disk1;" >> /etc/drbd.d/disk$drbdnum.res
if [ -z "$drbdport" ]; then
	echo "          address $ipaddr1:7789;" >> /etc/drbd.d/disk$drbdnum.res
else
	echo "          address $ipaddr1:$drbdport;" >> /etc/drbd.d/disk$drbdnum.res
fi
echo "          meta-disk internal;" >> /etc/drbd.d/disk$drbdnum.res
echo "     }" >> /etc/drbd.d/disk$drbdnum.res
echo "     on $fqdn2 {" >> /etc/drbd.d/disk$drbdnum.res
echo "          device $drbdnum;" >> /etc/drbd.d/disk$drbdnum.res
echo "          disk $disk2;" >> /etc/drbd.d/disk$drbdnum.res
if [ -z "$drbdport" ]; then
        echo "          address $ipaddr2:7789;" >> /etc/drbd.d/disk$drbdnum.res
else
        echo "          address $ipaddr2:$drbdport;" >> /etc/drbd.d/disk$drbdnum.res
fi
echo "          meta-disk internal;" >> /etc/drbd.d/disk$drbdnum.res
echo "     }" >> /etc/drbd.d/disk$drbdnum.res
echo "}" >> /etc/drbd.d/disk$drbdnum.res
echo "DRBD configuration file created /etc/drbd.d/disk$drbdnum"
echo "$ipaddr1 $fqdn1" >> /etc/hosts
echo "$ipaddr2 $fqdn2" >> /etc/hosts
/usr/bin/ssh root@$ipaddr2 echo "$ipaddr1 $fqdn1" >> /etc/hosts
/usr/bin/ssh root@$ipaddr2 echo "$ipaddr2 $fqdn2" >> /etc/hosts
/usr/bin/scp /etc/drbd.d/disk$drbdnum.res root@$ipaddr2:/etc/drbd.d/
/sbin/drbdadm create-md disk$drbdnum > /dev/null 2>&1
/usr/bin/ssh root@$ipaddr2 /sbin/drbdadm create-md disk$drbdnum > /dev/null 2>&1
/etc/init.d/drbd start & > /dev/null 2>&1
/usr/bin/ssh root@$ipaddr2 /etc/init.d/drbd start & > /dev/null 2>&1
/sbin/drbdadm -- --overwrite-data-of-peer primary disk$drbdnum > /dev/null 2>&1
/sbin/mkfs.ext4 /dev/drbd$drbdnum > /dev/null 2>&1
echo "Waiting 20 sec to finish up....!"
sleep 20
echo "..done...checking DRBD status:"
/bin/cat /proc/drbd
echo ""
echo ""
echo "Run \"drbdadm primary disk$drbdnum\" on the node you want to make primary!"
echo ""
echo ""
echo "Please make sure you sync your servers time with NTP server! Correct OS time is important!!"
