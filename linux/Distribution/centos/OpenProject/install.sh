#!/bin/bash
#
# Script-Name : install.sh
# Version : 0.0.1
# Autor : Tobias Kern
# Datum : 16-04-2014
# Lizenz : GPLv3
# Depends : wget , git
# Use : execute it
#  
# Description:
# Source: 
# https://www.openproject.org/projects/openproject/wiki/Installation_on_Centos_65_x64_with_Apache_and_PostgreSQL_93
####################################################################################################
## Notise: no tested
##
####################################################################################################
#

if [ `id -u` != 0 ]; then
    echo "Please login as ROOT user to execute your script : $@!"
    sleep 2
    exit 1
fi

# Update your system
yum update

# Install tools needed for DB and Ruby 
yum install git wget
yum - groupinstall "Development tools"

#Install some handy tools
yum -y install vim mlocate

#Create dedicated user for OP3
groupadd openproject
adduser -g openproject openproject


#useradd --create-home --gid openproject openproject
read -p "Enter your Password for openproject user" PWOPENPROJECT

passwd openproject $PWOPENPROJECT


#######################################################################################################
#
# Install Database PostGreSQL 9.3
#
#########################################################################################################

echo " I will open the /etc/yum.repos.d/CentOS-Base.repo file"
echo "and Edit for Preconfiguration Postgresql installation."

sleep 5

cat  > /etc/yum.repos.d/CentOS-Base.repo <<EOF
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the
# remarked out baseurl= line instead.
# 
#

[base]
name=CentOS-$releasever - Base
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
exclude=postgresql*

#released updates 
[updates]
name=CentOS-$releasever - Updates
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
baseurl=http://mirror.centos.org/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
exclude=postgresql*

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
#baseurl=http://mirror.centos.org/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus
#baseurl=http://mirror.centos.org/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#contrib - packages by Centos Users
[contrib]
name=CentOS-$releasever - Contrib
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=contrib
#baseurl=http://mirror.centos.org/centos/$releasever/contrib/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
EOF

# finish PostgreSQL installation

curl -O http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm

rpm -ivh pgdg-centos93-9.3-1.noarch.rpm
yum list postgres*
yum install postgresql93-server postgresql93-devel
service postgresql-9.3 initdb
chkconfig postgresql-9.3 on

echo 'openproject     openproject     openproject' >> /var/lib/pgsql/9.3/data/pg_ident.conf

# Uncomment this line in postgresql.conf file to allow connection to localhost of PostgreSQL service
# not working 

service postgresql-9.3 restart

#create databases
su - postgres
#### su - postgre ist not working in the bash shell!!!

psql -U postgres
##### psql -U postgres ist not working in the bash shell!!!

#CREATE ROLE openproject LOGIN ENCRYPTED PASSWORD 'my_password' NOINHERIT VALID UNTIL 'infinity';
#CREATE DATABASE openproject WITH ENCODING='UTF8' OWNER=openproject;
#CREATE DATABASE openproject_development WITH ENCODING='UTF8' OWNER=openproject;
#CREATE DATABASE openproject_test WITH ENCODING='UTF8' OWNER=openproject;

cat  > postgres_initial_openProject.sql <<EOF
CREATE ROLE openproject LOGIN ENCRYPTED PASSWORD 'my_password' NOINHERIT VALID UNTIL 'infinity';
CREATE DATABASE openproject WITH ENCODING='UTF8' OWNER=openproject;
CREATE DATABASE openproject_development WITH ENCODING='UTF8' OWNER=openproject;
CREATE DATABASE openproject_test WITH ENCODING='UTF8' OWNER=openproject;
EOF


# CREATEs not working make a file.sql for this error.

\q
exit


################################## Install Ruby ##########################################################
# Enable repo
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -Uvh epel-release-6*.rpm
yum update

# Install necessary packages for Ruby
yum search libyaml
yum -y install libyaml libxml2 libxml2-devel libxslt-devel libxml2-devel ruby-mysql mysql-devel ImageMagick-c++ ImageMagick-devel graphviz graphviz-ruby graphviz-devel memcached sqlite-devel

#Switch to user under which will OP run (user "openproject" in my case)
su openproject -c "bash -l"

# Switch to users home dir or whatever directory you want to install openproject
cd ~

#Add following line into profile file of the desired user:

echo "source ~/.profile" >> /home/openproject/.bash_profile

# Install RVM (Ruby Version Manager)
\curl -L https://get.rvm.io | bash -s stable 
source $HOME/.rvm/scripts/rvm

# Install Ruby via RVM
rvm autolibs disable
rvm install 2.1.0  # Libraries missing for ruby-2.1.0: libyaml-0.so.2. 
                  # Refer to your system manual for installing libraries
                  
                  #and this
                  
                  #Please be aware that you just installed 
                  #a ruby that requires 4 patches just to 
                  #be compiled on an up to date linux system.
                  #This may have known and unaccounted for 
                  #security vulnerabilities.
                  #Please consider upgrading to ruby-2.1.1 
                  #which will have all of the latest security patches

rvm reinstall ruby-2.1.0
rvm pkg install libyaml
rvm reinstall all --force
### error
gem install bundler


sleep 3

echo "Ruby bundle Version:$(bundle --version) is installed."

sleep 3
 
################################### Install OpenProject ##################################################
git clone https://github.com/opf/openproject.git
cd openproject
bundle install

#Please, 
#be aware that database configuration file and configuration file 
#are "ident-sensitive" and consistence of these files are crutial to have working environment
# (email notifications, database connections, etc.

#Create and configure file in ../openproject/config/database.yml.
#It should look like this:

cat  > database.yml <<EOF
production:
      adapter: postgresql
      encoding: utf8
      database: openproject
      pool: 5
      username: openproject
      password: openproject
development:
      adapter: postgresql
      encoding: utf8
      database: openproject_development
      pool: 5
      username: openproject
      password: openproject
test:
      adapter: postgresql
      encoding: utf8
      database: openproject_test
      pool: 5
      username: openproject
      password: openproject
EOF



# Configure email notifications (using gmail account) by creating configuration.yml in openproject/config directory

cat  > configuration.yml <<EOF
development:                         #main level
email_delivery_method: :smtp         #main level, will not work

default:                             #main level
  email_delivery_method: :smtp       #setting for default
  smtp_address: smtp.gmail.com       #setting for default
  smtp_port: 587
  smtp_domain: smtp.gmail.com
  smtp_user_name: ***@gmail.com
  smtp_password: ****
  smtp_enable_starttls_auto: true
  smtp_authentication: plain
EOF

Install plugins (Optional)
Create Gemfile.plugins file in openproject directory and paste these files:

#Please aware, that all of the plugins are currently in beta state, 
#so after final release, the installation could be different. 
#Consider this step and if you don't want to install plugins, 
#just skip this step and go to "Finish installation of OpenProject"

cat Gemfile.plugins > configuration.yml <<EOF
gem "pdf-inspector", "~>1.0.0", :group => :test
gem "openproject-meeting", :git => "https://github.com/finnlabs/openproject-meeting.git", :branch => "dev" 
gem "openproject-pdf_export", git: "https://github.com/finnlabs/openproject-pdf_export.git", :branch => "dev" 
gem "openproject-plugins", git: "https://github.com/opf/openproject-plugins.git", :branch => "dev" 
gem "openproject-backlogs", git: "https://github.com/finnlabs/openproject-backlogs.git", :branch => "dev"
EOF

##Finish installation of OpenProject
#
cd /home/openproject/openproject
bundle exec rake db:create:all
bundle exec rake db:migrate
bundle exec rake generate_secret_token
RAILS_ENV="production" bundle exec rake db:migrate

#Precompile OpenProjects assets
RAILS_ENV="production" bundle exec rake assets:precompile

##Install Apache with Passenger to autostart OpenProject with OS and loadbalance traffic
#
#Install necessary packages
yum install httpd curl-devel httpd-devel apr-devel apr-util-devel

#Grant permission for passenger
chmod o+x "/home/openproject" 

su - openproject -c "bash -l" 

#Install Passenger gem
gem install passenger

#Compile Passenger for Apache and follow instructions for pasting settings to httpd and virtualhost
#Just install it with default values and read statements if there are any errors :)
passenger-install-apache2-module

#Create VirtualHost file for Apache:
cat  /etc/httpd/conf.d/openproject.conf >  <<EOF
<VirtualHost *:80>
      ServerName www.myopenprojectsite.com
      # !!! Be sure to point DocumentRoot to 'public'!
      DocumentRoot /home/openproject/openproject/public    
      <Directory /home/openproject/openproject/public>
         # This relaxes Apache security settings.
         AllowOverride all
         # MultiViews must be turned off.
         Options -MultiViews
      </Directory>
   </VirtualHost>
EOF

#Finally disable temporarly SELINUX and iptables to be able to access your apache from another computer
setenforce 0
service iptables disable

#Start Apache
#
service httpd start

##################################################################################################################
##################################################################################################################
##################################################################################################################
#Now your OP should be accesible on IP address and port 80 (http) of the PC where you have successfully installed openproject.
#
#Please, notice, that disabling SELINUX and iptables is really not good way how to finish this installation. This guide is only for testing purposes and to be able to install OP as soon as possible. Configuring Apache (SSL etc.) and iptables is another topic.
#
#Any comments are appreciated here:
#https://www.openproject.org/topics/576?r=633.
exit 0
