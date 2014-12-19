#!/bin/bash
#
# Script-Name : otrs3ins.sh
# Version : 0.01
# Autor : Tobias Kern
# Datum : 19.12.2014
# Lizenz : GPLv3
# Depends :
# Use :
#
# Example:
#
# Description:
###########################################################################################
## Use it only if know what are you doing!
##
###########################################################################################
aptitude install libapache2-mod-perl2 libdbd-pg-perl libnet-dns-perl libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl libsoap-lite-perl libgd-text-perl libgd-graph-perl libapache-dbi-perl postgresql

useradd -r -d /opt/otrs/ -c 'OTRS user' otrs
usermod -g www-data otrs

cd /opt
 wget http://ftp.otrs.org/pub/otrs/otrs-3.0.5.tar.gz
 tar xf otrs-3.0.5.tar.gz
 mv otrs-3.0.5 otrs && cd otrs
 cp Kernel/Config.pm.dist Kernel/Config.pm
 cp Kernel/Config/GenericAgent.pm.dist Kernel/Config/GenericAgent.pm
 bin/otrs.SetPermissions.pl --otrs-user=otrs --otrs-group=otrs --web-user=www-data --web-group=www-data /opt/otrs
 ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/conf.d/otrs.conf 
 service apache2 restar

 su postgres
 psql

#On the psql command line
 create user otrs password 'otrs' nosuperuser;
 create database otrs owner otrs;
 \q

#Back in bash
 psql -U otrs -W -f scripts/database/otrs-schema.postgresql.sql otrs
 psql -U otrs -W -f scripts/database/otrs-initial_insert.postgresql.sql otrs
 psql -U otrs -W -f scripts/database/otrs-schema-post.postgresql.sql otrs

#Allow access to the db
 nano /etc/postgresql/8.4/main/pg_hba.conf

#put the following at the top of the file
 local   otrs    otrs    password
 host    otrs    otrs    127.0.0.1/32    password

exit (to stop being postgres)
 service postgresql restart

Configure OTRS for the DB
 nano Kernel/Config.pm
put in your password
 # DatabasePw
 # (The password of database user. You also can use bin/otrs.CryptPassword.pl
 # for crypted passwords.)
 $Self->{DatabasePw} = 'otrs';
comment out MySQL DSN
# DatabaseDSN
# (The database DSN for MySQL ==> more: "man DBD::mysql")
#$Self->{DatabaseDSN} = "DBI:mysql:database=$Self->{Database};host=$Self->{DatabaseHost};";
uncomment PG DSN, choosing local or tcpip (in this case local)
# (The database DSN for PostgreSQL ==> more: "man DBD::Pg")
# if you want to use a local socket connection
$Self->{DatabaseDSN} = "DBI:Pg:dbname=$Self->{Database};";
# if you want to use a tcpip connection
#    $Self->{DatabaseDSN} = "DBI:Pg:dbname=$Self->{Database};host=$Self->{DatabaseHost};";
nano scripts/apache2-perl-startup.pl
uncomment this bit
# enable this if you use postgresql
 use DBD::Pg ();
 use Kernel::System::DB::postgresql;
Install Cron jobs
 cd var/cron/ ; for foo in *.dist; do cp $foo `basename $foo .dist`; done ; cd ../..
 bin/Cron.sh start otrs

Start the real setup
Open a browser and go to http://localhost/otrs/index.pl
Log in with root@localhost, password root
