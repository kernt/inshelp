#!/bin/sh
# 
# ubuntu-nagios-core-4.0.2-v01.sh (22 Jan 2014)
# GeekPeek.Net scripts - Ubuntu Install Nagios Core 4.0.2 from sources
#
# INFO: This script was created and tested on fresh updated Ubuntu Server 12.04 LTS installation. The script installs 
# Nagios dependencies and downloads Nagios Core 4.0.2 tarball. It creates nagios user and group and compiles Nagios Core. 
# It creates Nagios Apache user and sets it's password. It hacks Nagios init script to work with Ubuntu if you want (y/n). It downloads and
# installs Nagios Plugins and configures Nagios Apache virtualhost. It makes Nagios and Apache to start on boot and starts both services.
#
# CODE:
/bin/echo "You must run this script as user root! Are you root? (y/n)"
read rootpriv
case $rootpriv in
	n)
		/bin/echo "Not root, exiting..."
		exit 2
		;;
	y)
/usr/sbin/useradd nagios
/usr/sbin/groupadd nagcmd
/usr/sbin/usermod -a -G nagcmd nagios
/usr/bin/apt-get update
/usr/bin/apt-get -y install build-essential apache2 php5-gd wget libgd2-xpm libgd2-xpm-dev libapache2-mod-php5 sendmail daemon
/usr/bin/wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.0.2.tar.gz
/bin/tar -xvzf nagios-4.0.2.tar.gz
cd nagios-4.0.2/
./configure --with-nagios-group=nagios --with-command-group=nagcmd --with-mail=/usr/bin/sendmail
/usr/bin/make all
/usr/bin/make install
/usr/bin/make install-init
/usr/bin/make install-config
/usr/bin/make install-commandmode
/usr/bin/make install-webconf
cd ..
/bin/cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
/bin/chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
/bin/echo ""
/bin/echo "Nagios init script does not work properly on default Nagios install."
/bin/echo "Do you want to apply Nagios init script hack? (y/n)"
read inithack
case $inithack in
	y)
	/bin/echo "Fixing Nagios init script for Ubuntu Server 12.04 LTS..."
	/bin/sed -i "s/^\.\ \/etc\/rc.d\/init.d\/functions$/\.\ \/lib\/lsb\/init-functions/g" /etc/init.d/nagios
	/bin/sed -i "s/status\ /status_of_proc\ /g" /etc/init.d/nagios
	/bin/sed -i "s/daemon\ --user=\$user\ \$exec\ -ud\ \$config/daemon\ --user=\$user\ --\ \$exec\ -d\ \$config/g" /etc/init.d/nagios
	/bin/sed -i "s/\/var\/lock\/subsys\/\$prog/\/var\/lock\/\$prog/g" /etc/init.d/nagios
	/bin/sed -i "s/\/sbin\/service\ nagios\ configtest/\/usr\/sbin\/service\ nagios\ configtest/g" /etc/init.d/nagios
	/bin/sed -i "s/\"\ \=\=\ \"/\"\ \=\ \"/g" /etc/init.d/nagios
	/bin/sed -i "s/\#\#killproc\ \-p\ \${pidfile\}\ \-d\ 10/killproc\ \-p \${pidfile\}/g" /etc/init.d/nagios
	/bin/sed -i "s/runuser/su/g" /etc/init.d/nagios
	/bin/sed -i "s/use_precached_objects=\"false\"/&\ndaemonpid=\$(pidof daemon)/" /etc/init.d/nagios
	/bin/sed -i "s/killproc\ -p\ \${pidfile}\ -d\ 10\ \$exec/\/sbin\/start-stop-daemon\ --user=\$user\ \$exec\ --stop/g" /etc/init.d/nagios
	/bin/sed -i "s/\/sbin\/start-stop-daemon\ --user=\$user\ \$exec\ --stop/&\n\tkill -9 \$daemonpid/" /etc/init.d/nagios
	;;
	n)
	/bin/echo "Skipping init hack..."
	;;
	*)
	/bin/echo "Unknown choice, skipping init hack..."
	;;
esac
/bin/echo "Please enter nagiosadmin password!"
/usr/bin/htpasswd -s -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
/usr/bin/wget http://www.nagios-plugins.org/download/nagios-plugins-1.5.tar.gz
/bin/tar -xvzf nagios-plugins-1.5.tar.gz
cd nagios-plugins-1.5/
./configure --with-nagios-user=nagios --with-nagios-group=nagios
/usr/bin/make
/usr/bin/make install
/bin/cp /etc/apache2/conf.d/nagios.conf /etc/apache2/sites-available/nagios
/bin/ln -s /etc/apache2/sites-available/nagios /etc/apache2/sites-enabled/nagios
/bin/chown nagios:www-data /usr/local/nagios/var/rw
/bin/ln -s /etc/init.d/nagios /etc/rcS.d/S98nagios
/bin/ln -s /etc/init.d/apache2 /etc/rcS.d/S99apache2
/etc/init.d/nagios start
/etc/init.d/apache2 restart
/bin/echo ""
/bin/echo "Open http://IPADDRESS/nagios or http://FQDN/nagios in your browser and enter nagiosadmin username and password!"
;;
	*)
		/bin/echo "Unknown choice, exiting..."
		exit 2
		;;
esac
