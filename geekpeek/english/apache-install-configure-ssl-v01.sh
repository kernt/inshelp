#!/bin/sh
# 
# apache-install-configure-ssl-v01.sh (2 August 2013)
# GeekPeek.Net scripts - Install and configure Apache Virtual Hosts and SSL
#
# INFO: This script was created and tested on fresh CentOS 6.4 minimal installation. This script enables you 
# to install and configure Apache, Apache Virtual Hosts (HTTP, HTTPS) and SSL.  With easy numbered choice menu
# you can choose what you want to install and configure. You can install Apache, mod_ssl, configure HTTP Vhost,
# HTTPS Vhost, add ServerName and NameVirtualHost directives to httpd.conf.
#
# CODE:
scriptloop="y"
while [ "$scriptloop" = "y" ]; do
/bin/echo ""
/bin/echo "GEEKPEEK.NET APACHE CONFIG SCRIPT"
/bin/echo "1 - Install Apache Server"
/bin/echo "2 - Install SSL Apache module"
/bin/echo "3 - Insert ServerName directive to httpd.conf file"
/bin/echo "4 - Insert NameVirtualHost *:80 directive to httpd.conf file"
/bin/echo "5 - Insert NameVirtualHost *:443 directive to httpd.conf file"
/bin/echo "6 - Configure HTTP Virtual Host on port 80 (no mod_ssl)"
/bin/echo "7 - Configure HTTPS Virtual Host on port 443 (permanent rewrite rule HTTP -> HTTPS - mod_ssl)"
/bin/echo "8 - Configure HTTP Virtual Host on port 80 with HTTP -> HTTPS rewrite rule (mod_ssl)"
/bin/echo ""
/bin/echo "q - EXIT APACHE CONFIG SCRIPT!"
/bin/echo ""
/bin/echo "Please enter NUMBER of choice (example: 3):"
read choice
case $choice in
1)
	/bin/echo "Installing Apache Server..."
	/usr/bin/yum install httpd -y
	/sbin/chkconfig httpd on
	service httpd start
	;;
2)
	/bin/echo "Installing SSL Apache module..."
	/usr/bin/yum install mod_ssl -y
	service httpd reload
	;;
3)
        /bin/echo "Please enter your web server FQDN (example: foo1.geekpeek.net):"
        read fqdn
        /bin/echo "ServerName $fqdn" >> /etc/httpd/conf/httpd.conf
        ;;
4)
        /bin/echo "NameVirtualHost *:80" >> /etc/httpd/conf/httpd.conf
        ;;
5)
        /bin/echo "NameVirtualHost *:443" >> /etc/httpd/conf/httpd.conf
        ;;
6)
	checkhttpd=$(/bin/rpm -qi httpd |grep Install)
	if [ -z "$checkhttpd" ]; then
	        /bin/echo "Appache server not installed - installing Apache Server..."
	        /usr/bin/yum install httpd -y
	        /sbin/chkconfig httpd on
	        service httpd start;
	fi
	/bin/echo "Creating config file....Please enter the name of the new HTTP Virtual Host (example: website1):"
	read vhostname
	conffile=$(ls -la /etc/httpd/conf.d/$vhostname.conf > /dev/null 2>&1)
	if [ -z "$conffile" ]; then
                /bin/echo "Please enter the DocumentRoot directory (example: /var/www/html):"
                read documentroot
		/bin/mkdir $documentroot > /dev/null 2>&1
                /bin/echo "Please enter ServerName (example: www.geekpeek.net):"
                read servername
                /bin/echo "Please enter ServerAdmin email address (example: info@geekpeek.net):"
                read adminemail
                /bin/echo "Please enter Virtual Host log files location (example: /var/log/httpd/geekpeek):"
                read loglocation
		/bin/mkdir $loglocation > /dev/null 2>&1
		/bin/echo "Generating $vhostname config file..."
		/bin/echo "<VirtualHost *:80>" >> /etc/httpd/conf.d/$vhostname.conf
                /bin/echo "   ServerAdmin $adminemail" >> /etc/httpd/conf.d/$vhostname.conf
		/bin/echo "   ServerName $servername" >> /etc/httpd/conf.d/$vhostname.conf
		/bin/echo "   DocumentRoot $documentroot" >> /etc/httpd/conf.d/$vhostname.conf
                /bin/echo "   ErrorLog $loglocation/$vhostname-error.log" >> /etc/httpd/conf.d/$vhostname.conf
		/bin/echo "   CustomLog $loglocation/$vhostname-common.log common" >> /etc/httpd/conf.d/$vhostname.conf
		/bin/echo "</VirtualHost>" >> /etc/httpd/conf.d/$vhostname.conf
		/bin/echo "$vhostname config file succesfully created!"
	else
        /bin/echo "Virtual Host config file already exists...exiting!"
        fi
	;;
7)
        checkssl=$(/bin/rpm -qa |grep mod_ssl)
        if [ -z "$checkssl" ]; then
                /bin/echo "Apache SSL module not installed - installing..."
                /usr/bin/yum install mod_ssl -y
                /sbin/chkconfig httpd on
                service httpd restart;
	fi
	/bin/echo "Creating config file....Please enter the name of the new HTTPS Virtual Host (example: website2):"
        read vhostname
        conffile=$(ls -la /etc/httpd/conf.d/$vhostname.conf > /dev/null 2>&1)
        if [ -z "$conffile" ]; then
                /bin/echo "Please enter the DocumentRoot directory (example: /var/www/html):"
                read documentroot
		/bin/mkdir $documentroot > /dev/null 2>&1
                /bin/echo "Please enter ServerName (example: www.geekpeek.net):"
                read servername
                /bin/echo "Please enter ServerAdmin email address (example: info@geekpeek.net):"
                read adminemail
                /bin/echo "Please enter Virtual Host log files location (example: /var/log/httpd/geekpeek):"
                read loglocation
		/bin/echo "Enter location of the SIGNED SSL certificate or LEAVE EMPTY for default self signed SSL certificate config (example: /etc/httpd/conf.d/ssl/mycert.crt):"
		read sslcert
                /bin/echo "Enter location of the SIGNED certificate KEY FILE or LEAVE EMPTY for default SSL certificate key file (example: /etc/httpd/conf.d/ssl/mycert.key):"
                read sslkey
                /bin/mkdir $loglocation > /dev/null 2>&1
                /bin/echo "Generating $vhostname config file..."
                        /bin/echo "<VirtualHost *:80>" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "   ServerAdmin $adminemail" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "   ServerName $servername" >> /etc/httpd/conf.d/$vhostname.conf
			/bin/echo "     RewriteEngine On" >> /etc/httpd/conf.d/$vhostname.conf
			/bin/echo "     RewriteCond %{HTTPS} !=on" >> /etc/httpd/conf.d/$vhostname.conf
			/bin/echo "     RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L]" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "</VirtualHost>" >> /etc/httpd/conf.d/$vhostname.conf
			/bin/echo "" >> /etc/httpd/conf.d/$vhostname.conf
			/bin/echo "<VirtualHost *:443>" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "   ServerAdmin $adminemail" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "   ServerName $servername" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "   DocumentRoot $documentroot" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "   ErrorLog $loglocation/$vhostname-error.log" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "   CustomLog $loglocation/$vhostname-common.log common" >> /etc/httpd/conf.d/$vhostname.conf
		        /bin/echo "     SSLEngine on" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "     SSLProtocol all -SSLv2" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "	SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:!RC4+RSA:+HIGH:+MEDIUM:!LOW:!RC4" >> /etc/httpd/conf.d/$vhostname.conf
		if [ -z "$sslcert" ]; then
                        /bin/echo "	SSLCertificateFile /etc/pki/tls/certs/localhost.crt" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "	SSLCertificateKeyFile /etc/pki/tls/private/localhost.key" >> /etc/httpd/conf.d/$vhostname.conf
		else
                        /bin/echo "     SSLCertificateFile $sslcert" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "     SSLCertificateKeyFile $sslkey" >> /etc/httpd/conf.d/$vhostname.conf;
		fi

                        /bin/echo "</VirtualHost>" >> /etc/httpd/conf.d/$vhostname.conf
	                /bin/echo "$vhostname config file succesfully created!"
	else
	/bin/echo "Virtual Host config file already exists...exiting!"
	fi;
	;;
8)
        checkssl=$(/bin/rpm -qa |grep mod_ssl)
        if [ -z "$checkssl" ]; then
                /bin/echo "Apache SSL module not installed - installing..."
                /usr/bin/yum install mod_ssl -y
                /sbin/chkconfig httpd on
                service httpd restart;
	fi
	/bin/echo "Creating config file....Please enter the name of the new HTTP Virtual Host (example: website2):"
        read vhostname
        conffile=$(ls -la /etc/httpd/conf.d/$vhostname.conf > /dev/null 2>&1)
        if [ -z "$conffile" ]; then
                /bin/echo "Please enter the DocumentRoot directory (example: /var/www/html):"
                read documentroot
		/bin/mkdir $documentroot > /dev/null 2>&1
                /bin/echo "Please enter ServerName (example: www.geekpeek.net):"
                read servername
                /bin/echo "Please enter ServerAdmin email address (example: info@geekpeek.net):"
                read adminemail
                /bin/echo "Please enter Virtual Host log files location (example: /var/log/httpd/geekpeek):"
                read loglocation
		/bin/echo "Enter location of the SIGNED SSL certificate or LEAVE EMPTY for default self signed SSL certificate config (example: /etc/httpd/conf.d/ssl/mycert.crt):"
		read sslcert
                /bin/echo "Enter location of the SIGNED certificate KEY FILE or LEAVE EMPTY for default SSL certificate key file (example: /etc/httpd/conf.d/ssl/mycert.key):"
                read sslkey
                /bin/mkdir $loglocation > /dev/null 2>&1
                /bin/echo "Generating $vhostname config file..."
	                /bin/echo "<VirtualHost *:80>" >> /etc/httpd/conf.d/$vhostname.conf
	                /bin/echo "   ServerAdmin $adminemail" >> /etc/httpd/conf.d/$vhostname.conf
        	        /bin/echo "   ServerName $servername" >> /etc/httpd/conf.d/$vhostname.conf
	                /bin/echo "   DocumentRoot $documentroot" >> /etc/httpd/conf.d/$vhostname.conf
	                /bin/echo "   ErrorLog $loglocation/$vhostname-error.log" >> /etc/httpd/conf.d/$vhostname.conf
        	        /bin/echo "   CustomLog $loglocation/$vhostname-common.log common" >> /etc/httpd/conf.d/$vhostname.conf
	                /bin/echo "</VirtualHost>" >> /etc/httpd/conf.d/$vhostname.conf
			/bin/echo "" >> /etc/httpd/conf.d/$vhostname.conf
			/bin/echo "<VirtualHost *:443>" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "   ServerAdmin $adminemail" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "   ServerName $servername" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "     RewriteEngine On" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "     RewriteCond %{HTTP} !=on" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "     RewriteRule ^/?(.*) http://%{SERVER_NAME}/$1 [R,L]" >> /etc/httpd/conf.d/$vhostname.conf
		        /bin/echo "     SSLEngine on" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "     SSLProtocol all -SSLv2" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "	SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:!RC4+RSA:+HIGH:+MEDIUM:!LOW:!RC4" >> /etc/httpd/conf.d/$vhostname.conf
		if [ -z "$sslcert" ]; then
                        /bin/echo "	SSLCertificateFile /etc/pki/tls/certs/localhost.crt" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "	SSLCertificateKeyFile /etc/pki/tls/private/localhost.key" >> /etc/httpd/conf.d/$vhostname.conf
		else
                        /bin/echo "     SSLCertificateFile $sslcert" >> /etc/httpd/conf.d/$vhostname.conf
                        /bin/echo "     SSLCertificateKeyFile $sslkey" >> /etc/httpd/conf.d/$vhostname.conf;
		fi

                        /bin/echo "</VirtualHost>" >> /etc/httpd/conf.d/$vhostname.conf
	                /bin/echo "$vhostname config file succesfully created!"
	else
	/bin/echo "Virtual Host config file already exists...exiting!"
	fi;
	;;
q)
        scriptloop="n"
	/etc/init.d/httpd reload
        ;;
*)
        /bin/echo "Unknown choice! Exiting..."
        ;;
esac
done
