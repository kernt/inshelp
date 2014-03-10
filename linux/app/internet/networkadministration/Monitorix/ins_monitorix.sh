# add Apt repository from IzzySoft 
echo ""deb http://apt.izzysoft.de/ubuntu generic universe >> /etc/apt/sources.list.d/izzysoft.list

# or use this file http://www.monitorix.org/monitorix_3.4.0-izzy1_all.deb
# wget http://www.monitorix.org/monitorix_3.4.0-izzy1_all.deb
# execute to install
# dpkg -i monitorix_3.4.0-izzy1_all.debpt-get update
# apt-get install rrdtool perl libwww-perl libmailtools-perl libmime-lite-perl librrds-perl \
#libdbi-perl libxml-simple-perl libhttp-server-simple-perl libconfig-general-perl
# dpkg -i monitorix*.deb


# add key 
wget -q "http://apt.izzysoft.de/izzysoft.asc" -O- | sudo apt-key add -

exit 0
