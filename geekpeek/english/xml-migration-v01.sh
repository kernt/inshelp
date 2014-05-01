#!/bin/sh
# 
# xml-migration-v01.sh (5 June 2013)
# GeekPeek.Net scripts - XML migration script
#
# INFO: This script was created and tested on fresh CentOS 6.4 minimal installation. The script migrates
# RRD XML files from one to another computer via rsync. It creates new directories if neccessary. The
# script migrates files to the same directory as on they were on source computer.
#
# REQUIREMENTS: works best with rrd2xl-convert-v01.sh and xml2rrd-convert-v01.sh
#
# CODE:
/bin/echo "Enter the IP address of the host to migrate data to. (example: 192.168.1.100)"
read migratehost
/bin/echo "What is the location of your RRD XML files? (example: /usr/local/pnp4nagios/var/perfdata)"
read xmldatadir
/bin/echo "For this script to work as expected, you need to enable root SSH access on the second machine."
/bin/echo "Is SSH root access enabled on the second machine? Press n to exit! (y/n)"
read rootssh
case $rootssh in
        y)
                /bin/echo "Generating SSH key - press Enter a couple of times..."
                /usr/bin/ssh-keygen
                /bin/echo "Copying SSH key to the second machine..."
                /bin/echo "Please enter root password for the second machine."
                /usr/bin/ssh-copy-id root@$migratehost
                /bin/echo "Succesfully set up SSH with key authentication...continuing with RRD XML migration..."
                ;;
        n)
                /bin/echo "Root access must be enabled on the second machine...exiting!"
                exit 1
                ;;
esac
/bin/echo "Installing rsync on both machines..."
/usr/bin/yum install rsync -y
/bin/echo "Transferring files..."
/usr/bin/ssh root@$migratehost /usr/bin/yum install rsync -y
/bin/find $xmldatadir -name \*.rrd.xml > rrdxmllist.txt
while read xmlrrd
do
        /bin/echo "Transferring $xmlrrd file." >> xml-migration.log
	/bin/echo "Transferring $xmlrrd file."
	xmldir=${xmlrrd%/*}
	/bin/echo $xmldir >> xmldirfile
	/bin/sed -ie 's/$/\//' xmldirfile
	xmldir=$(cat xmldirfile)
        /usr/bin/rsync -avre ssh $xmlrrd root@$migratehost:$xmldir >> xml-migration.log
	/bin/rm -rf xmldirfile
	/bin/rm -rf $xmlrrd
done < rrdxmllist.txt
/bin/rm -rf rrdxmllist.txt
/bin/rm -rf xmldirfilee
echo "Please take a look at xml-migration.log file for additional information about file migration."
