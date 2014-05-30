#!/usr/bin/env bash
#
# Script-Name : install.sh
# Version : 0.0.1
# Autor : Tobias Kern
# Datum : 16-04-2014
# Lizenz : GPLv3
# Depends : wget , git, Ruby >= 2.1.0, Bundler, Database (mysql 5.x||postgresql 8.x)
# Use : execute it
#  
# Description:
# Source: 
#
####################################################################################################
## Notise: no tested
##
####################################################################################################
#

TMPDIR=/tmp/

if [ `id -u` != 0 ]; then
    echo "Please login as ROOT user to execute your script : $@!"
    sleep 2
    exit 1
fi

# Update your system
apt-get update

# Install tools needed for DB and Ruby 
apt-get -y install git wget curl

#Install some handy tools
apt-get -y install vim mlocate
apt-get -y install postgresql-9.1 make libxml2-dev libxslt-dev g++ libpq-dev

#Create dedicated user for OP3
groupadd openproject
useradd -mg openproject openproject

#useradd --create-home --gid openproject openproject
read -p "Enter your Password for openproject user" PWOPENPROJECT
passwd openproject $PWOPENPROJECT

#######################################################################################################
#
# Install Database PostGreSQL 9.3
#
#########################################################################################################

echo 'openproject     openproject     openproject' >> /etc/postgresql/9.1/main/pg_ident.conf

# Uncomment this line in postgresql.conf file to allow connection to localhost of PostgreSQL service
# not working 

service postgresql restart

#create databases
su - postgres
#### su - postgre ist not working in the bash shell!!!
psql -U postgres
##### psql -U postgres ist not working in the bash shell!!!

psql -h localhost -U postgres -W -c "CREATE ROLE openproject LOGIN ENCRYPTED PASSWORD 'my_password' NOINHERIT VALID UNTIL 'infinity';"
psql -h localhost -U postgres -W -c "CREATE DATABASE openproject WITH ENCODING='UTF8' OWNER=openproject;"
psql -h localhost -U postgres -W -c "CREATE DATABASE openproject_development WITH ENCODING='UTF8' OWNER=openproject;"
psql -h localhost -U postgres -W -c "DATABASE openproject_test WITH ENCODING='UTF8' OWNER=openproject;"

# CREATEs not working make a file.sql for this error.
\q
exit

################################## Install Ruby ##########################################################

# give openproject user right to use rvm 
#usermod -a -G rvm openproject

curl -sSL https://get.rvm.io | bash -s stable --ruby=2.1
source /etc/profile.d/rvm.sh

#Switch to user under which will OP run (user "openproject" in my case)
su openproject -c "bash -l"

# Switch to users home dir or whatever directory you want to install openproject
cd ~
rvm reinstall ruby-2.1.2

#Add following line into profile file of the desired user:

echo "source ~/.profile" >> /home/openproject/.bash_profile

# print on screen your Ruby version
echo "You use on your os the following Ruby version"
ruby -v

# Install RVM (Ruby Version Manager)
\curl -L https://get.rvm.io | bash -s stable 

# error $HOME/.rvm/scripts/rvm not exisdent
source $HOME/.rvm/scripts/rvm

# Install Ruby via RVM
gem install bundler --version '>=1.5.1'

rvm autolibs disable
rvm install 2.1.0       # Libraries missing for ruby-2.1.0: libyaml-0.so.2. 
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
# error
# ...
# 'rvm pkg ...' is deprecated, read about the new autolibs feature: 'rvm help autolibs'
#
#
#
#
#Please note that it's required to reinstall all rubies:
#rvm reinstall all --force
#
#Unknown ruby interpreter version (do not know how to handle): all.
#######################################################################
#No binary rubies available for: debian/7/x86_64/ruby-2.1.2.
#Please read 'rvm help mount' to get more information on binary rubies.
# ...
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

cat  > /home/openproject/config/database.yml <<EOF
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
cat  > ${TMPDIR}configuration.yml <<EOF
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
cd /home/openproject/openproject
bundle exec rake db:create:all
bundle exec rake db:migrate
bundle exec rake generate_secret_token
RAILS_ENV="production" bundle exec rake db:migrate

#Precompile OpenProjects assets
RAILS_ENV="production" bundle exec rake assets:precompile

##Install Apache with Passenger to autostart OpenProject with OS and loadbalance traffic
#Grant permission for passenger
chmod o+x "/home/openproject" 

su - openproject -c "bash -l"

#Install Passenger gem
gem install passenger

#Compile Passenger for Apache and follow instructions for pasting settings to httpd and virtualhost
#Just install it with default values and read statements if there are any errors :)
passenger-install-apache2-module

#Create VirtualHost file for Apache:
cat  /etc/apache2/conf.d/openproject.conf >  <<EOF
      # !!! Be sure to point DocumentRoot to 'public'!
      Alias     /openproject/            /home/openproject/openproject/public
      #DocumentRoot /home/openproject/openproject/public
          
      <Directory /home/openproject/openproject/public>
         # This relaxes Apache security settings.
         AllowOverride all
         # MultiViews must be turned off.
         Options -MultiViews
      </Directory>
EOF

#Start Apache
#
service apache2 restart

##################################################################################################################
#Now your OP should be accesible on IP address and port 80 (http) of the PC where you have successfully installed openproject.
#
#Please, notice, that disabling SELINUX and iptables is really not good way how to finish this installation. This guide is only for testing purposes and to be able to install OP as soon as possible. Configuring Apache (SSL etc.) and iptables is another topic.
#
#Any comments are appreciated here:
#https://www.openproject.org/topics/576?r=633.
exit 0
