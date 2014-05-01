#!/bin/sh
# 
# install-openvpn-server-v01.sh (28 February 2014)
# GeekPeek.Net scripts - Install OpenVPN Server
#
# INFO: This script was created and tested on fresh CentOS 6.5 minimal installation with IPtables and SELinux disabled. 
# This script installs RPMForge repository and packages necessary for OpenVPN configuration. It creates certificates,
# builds CA file, Key Server and Diffie Hellman. It creates OpenVPN server configuration file and enabled IP forwarding
# in /etc/sysctl.conf. It creates a new user on the system for VPN login. In the end it starts OpenVPN service.
#
# VARS:
architecture=$(uname -i)
# CODE:
/bin/echo ""
/bin/echo "Installing RPMForge repository..."
/bin/echo ""
case $architecture in
        i386 )
		/bin/rpm -Uvh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.i686.rpm
                ;;
        x86_64 )
		/bin/rpm -Uvh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
                ;;
        * )
                /bin/echo "Unknown architecture! Exiting..."
                exit 3
                ;;
esac
/bin/echo ""
/bin/echo "Installing necessary packages..."
/bin/echo ""
/usr/bin/yum install gcc make rpm-build autoconf.noarch zlib-devel pam-devel openssl-devel lzo openvpn wget -y
/bin/echo ""
/bin/echo "Copying folders..."
/bin/echo ""
/bin/cp -R /usr/share/doc/openvpn-*/* /etc/openvpn
/bin/echo ""
/bin/echo "Creating certificate..."
/bin/echo ""
cd /etc/openvpn/easy-rsa/2.0
/bin/chmod 755 *
source ./vars
./vars
./clean-all
/bin/echo ""
/bin/echo "Building CA file... Please enter the requested information!"
/bin/echo ""
./build-ca
/bin/echo ""
/bin/echo "Building Key Server... Please enter the requested information!"
/bin/echo ""
./build-key-server server
/bin/echo ""
/bin/echo "Building Diffie Hellman..."
/bin/echo ""
./build-dh
/bin/echo "# IP address you want to bind OpenVPN Server to" >> /etc/openvpn/server.conf
/bin/echo "#local 89.212.236.50" >> /etc/openvpn/server.conf
/bin/echo "" >> /etc/openvpn/server.conf
/bin/echo "# Pick the desired VPN port number - default 1194" >> /etc/openvpn/server.conf
/bin/echo "#port 4444" >> /etc/openvpn/server.conf
/bin/echo "proto udp" >> /etc/openvpn/server.conf
/bin/echo "" >> /etc/openvpn/server.conf
/bin/echo "# We use TUN when setting separate IPs on a VPN Network" >> /etc/openvpn/server.conf
/bin/echo "dev tun" >> /etc/openvpn/server.conf
/bin/echo "tun-mtu 1500" >> /etc/openvpn/server.conf
/bin/echo "tun-mtu-extra 32" >> /etc/openvpn/server.conf
/bin/echo "mssfix 1450" >> /etc/openvpn/server.conf
/bin/echo "reneg-sec 0" >> /etc/openvpn/server.conf
/bin/echo "" >> /etc/openvpn/server.conf
/bin/echo "# Adjust paths as needed." >> /etc/openvpn/server.conf
/bin/echo "ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt" >> /etc/openvpn/server.conf
/bin/echo "cert /etc/openvpn/easy-rsa/2.0/keys/server.crt" >> /etc/openvpn/server.conf
/bin/echo "key /etc/openvpn/easy-rsa/2.0/keys/server.key" >> /etc/openvpn/server.conf
/bin/echo "dh /etc/openvpn/easy-rsa/2.0/keys/dh1024.pem" >> /etc/openvpn/server.conf
/bin/echo "plugin /usr/share/openvpn/plugin/lib/openvpn-auth-pam.so /etc/pam.d/login # Comment this line if you are using FreeRADIUS" >> /etc/openvpn/server.conf
/bin/echo "#plugin /etc/openvpn/radiusplugin.so /etc/openvpn/radiusplugin.cnf # Uncomment this line if you are using FreeRADIUS" >> /etc/openvpn/server.conf
/bin/echo "client-cert-not-required # No client specific certificates required" >> /etc/openvpn/server.conf
/bin/echo "username-as-common-name" >> /etc/openvpn/server.conf
/bin/echo "" >> /etc/openvpn/server.conf
/bin/echo "# The Pool of IPs in the 'VPN Network'" >> /etc/openvpn/server.conf
/bin/echo "server 172.26.1.0 255.255.255.0 # Change this to reflect your Network environment" >> /etc/openvpn/server.conf
/bin/echo "" >> /etc/openvpn/server.conf
/bin/echo "push "redirect-gateway def1"" >> /etc/openvpn/server.conf
/bin/echo "push "dhcp-option DNS 8.8.8.8"" >> /etc/openvpn/server.conf
/bin/echo "push "dhcp-option DNS 8.8.4.4"" >> /etc/openvpn/server.conf
/bin/echo "keepalive 5 30" >> /etc/openvpn/server.conf
/bin/echo "comp-lzo" >> /etc/openvpn/server.conf
/bin/echo "persist-key" >> /etc/openvpn/server.conf
/bin/echo "persist-tun" >> /etc/openvpn/server.conf
/bin/echo "status 1194.log" >> /etc/openvpn/server.conf
/bin/echo "verb 3" >> /etc/openvpn/server.conf
/bin/echo ""
/bin/echo "Enabling IP Forwarding..."
/bin/echo ""
/bin/sed -i "s/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g" /etc/sysctl.conf
/sbin/sysctl -p
/bin/echo ""
/bin/echo "Please enter the username for VPN login:"
read vpnuser
vpnuserchk=$(/bin/grep $vpnuser /etc/passwd)
if [ -z "$vpnuserchk" ]; then
	/usr/sbin/useradd $vpnuser
	/bin/echo "Please enter the password for $vpnuser:"
	/usr/bin/passwd $vpnuser
else
	/bin/echo "User $vpnuser already exists on the system. You will have to add a different user manually when this script completes!"
fi
/bin/echo ""
/bin/echo "Starting OpenVPN Server..."
/bin/echo ""
/etc/init.d/openvpn start
/bin/echo ""
/bin/echo "GeekPeek.Net OpenVPN Server bash script is finished."
/bin/echo "You must transfer /etc/openvpn/easy-rsa/2.0/keys/ca.crt file to your client, configure it and try logging to your VPN!"
/bin/echo ""
