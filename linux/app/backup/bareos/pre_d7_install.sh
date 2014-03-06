## install bareos on Debian 7
#
######################## pre Install #####################################################
echo "http://download.bareos.org/bareos/release/latest/Debian_7.0/" > > bareos.list
wget -q "http://download.bareos.org/bareos/release/latest/Debian_7.0/Release.key" -O- | apt-key add -
# for Ubuntu
# wget -q "http://download.bareos.org/bareos/release/latest/Debian_7.0/Release.key" -O- | sudo apt-key add -
apt-get update
