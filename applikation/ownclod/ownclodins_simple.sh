#!/bin/bash
#
# Script-Name : ownclodins_simple.sh
# Version : 0.01
# Autor : Tobias Kern
# Datum : $DATE
# Lizenz : GPLv3
# Depends : git apache2
# Use :
#
# Example:
#
# Description:
###########################################################################################
## 
##
###########################################################################################

git clone git://gitorious.org/owncloud/owncloud.git

setfacl -Rm d:u:$USER:rwx,u:www-data:rwx owncloud/

chown -R www-data:www-data owncloud/

Enable the .htaccess if that’s not automatic for your server

# You need to edit /etc/apache2/sites-enabled/000-default, 
# look for /var/www and change AllowOverride None to AllowOverride All if not already set. 
# Otherwise your files will be viewable from the web.

/etc/apache2/sites-enabled/000-default

#Then restart Apache: 
sudo /etc/init.d/apache2 restart
