#!/bin/sh
# 
# install-pxe-server-v01.sh (3 January 2014)
# GeekPeek.Net scripts - Install and configure PXE Server on CentOS 6
#
# INFO: This script was created and tested on fresh CentOS 6.5 minimal installation. The script must be run on box where
# DHCP Server is installed and configured. This script installes syslinux, tftp server and httpd packages. It creates necessary
# directories and configuration files for TFTP and PXE Server. It creates a /tftpboot/centos6/i386 directory to put CentOS 6 boot files
# to. It reconfigures DHCP to allow PXE boot. It restarts xinetd, dhcp and httpd services. This script does not transfer CentOS 6 DVD or
# boot files to your server. You need to do this manually.
#
# CODE:
echo "Is DHCP Server installed and configured on this server? (y/n)"
read dhcpserv
if [ $dhcpserv == "n" ]; then
	echo "You must run this script on the server where DHCP Server is installed. Exiting..."
	exit 2;
else
echo "Please enter the IP address you want to run PXE Server on. (example: 192.168.1.5)"
read pxeip
/usr/bin/yum install tftp-server syslinux httpd -y
/bin/mkdir /tftpboot
/bin/cp /usr/share/syslinux/pxelinux.0 /tftpboot/
/bin/cp /usr/share/syslinux/menu.c32 /tftpboot/
/bin/cp /usr/share/syslinux/memdisk /tftpboot/
/bin/cp /usr/share/syslinux/mboot.c32 /tftpboot/
/bin/cp /usr/share/syslinux/chain.c32 /tftpboot/
/bin/mkdir /tftpboot/pxelinux.cfg
/bin/mkdir -p /tftpboot/centos6/i386
/bin/sed -i "s/server_args\t\t= -s \/var\/lib\/tftpboot/server_args\t\t= -s \/tftpboot/g" /etc/xinetd.d/tftp
/bin/sed -i "s/disable\t\t\t= yes/disable\t\t\t= no/g" /etc/xinetd.d/tftp
echo "Creating PXE Server Menu..."
echo "default menu.c32" >> /tftpboot/pxelinux.cfg/default
echo "prompt 0" >> /tftpboot/pxelinux.cfg/default
echo "timeout 300" >> /tftpboot/pxelinux.cfg/default
echo "ONTIMEOUT local" >> /tftpboot/pxelinux.cfg/default
echo "" >> /tftpboot/pxelinux.cfg/default
echo "menu title ########## PXE Boot Menu ##########" >> /tftpboot/pxelinux.cfg/default
echo "label 1" >> /tftpboot/pxelinux.cfg/default
echo "   menu label ^1) Install CentOS 6 i386" >> /tftpboot/pxelinux.cfg/default
echo "   kernel centos6/i386/images/pxeboot/vmlinuz" >> /tftpboot/pxelinux.cfg/default
echo "   append initrd=centos6/i386/images/pxeboot/initrd.img method=http://$pxeip/centos6/i386 devfs=nomount" >> /tftpboot/pxelinux.cfg/default
echo "" >> /tftpboot/pxelinux.cfg/default
echo "label 2" >> /tftpboot/pxelinux.cfg/default
echo "   menu label ^2) Boot from local drive" >> /tftpboot/pxelinux.cfg/default
echo "   localboot" >> /tftpboot/pxelinux.cfg/default
echo "Re-Configuring DHCP Server..."
echo "" >> /etc/dhcp/dhcpd.conf
echo "# GeekPeek.Net scripts - Added for PXE Server configuration" >> /etc/dhcp/dhcpd.conf
echo "allow booting;" >> /etc/dhcp/dhcpd.conf
echo "allow bootp;" >> /etc/dhcp/dhcpd.conf
echo "option option-128 code 128 = string;" >> /etc/dhcp/dhcpd.conf
echo "option option-129 code 129 = text;" >> /etc/dhcp/dhcpd.conf
echo "next-server $pxeip;" >> /etc/dhcp/dhcpd.conf
echo "filename \"pxelinux.0\";" >> /etc/dhcp/dhcpd.conf
echo "Creating PXE Server Apache Config File..."
net=$(echo $pxeip | awk -F. '{print$1"."$2"."$3".0"}')
echo "Alias /centos6/i386 /tftpboot/centos6/i386" >> /etc/httpd/conf.d/pxeboot.conf
echo "" >> /etc/httpd/conf.d/pxeboot.conf
echo "<Directory /tftpboot/centos6/i386>" >> /etc/httpd/conf.d/pxeboot.conf
echo "   Options Indexes FollowSymLinks" >> /etc/httpd/conf.d/pxeboot.conf
echo "   Order Deny,Allow" >> /etc/httpd/conf.d/pxeboot.conf
echo "   Deny from all" >> /etc/httpd/conf.d/pxeboot.conf
echo "   Allow from 127.0.0.1 $net/24" >> /etc/httpd/conf.d/pxeboot.conf
echo "</Directory>" >> /etc/httpd/conf.d/pxeboot.conf
chkconfig xinetd on
chkconfig dhcpd on
chkconfig httpd on
/etc/init.d/xinetd restart
/etc/init.d/dhcpd restart
/etc/init.d/httpd restart
fi
echo "Now you need to mount CentOS 6 ISO or copy CentOS 6 DVD contents to /tftpboot/centos6/i386!"
