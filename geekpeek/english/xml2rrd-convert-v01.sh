#!/bin/sh
# 
# xml2rrd-convert-v01.sh (5 June 2013)
# GeekPeek.Net scripts - XML2RRD convert script
#
# INFO: This script was created and tested on fresh CentOS 6.4 minimal installation. The script installs 
# RRDTool and dependencies. It creates a list of XML RRD files from selected folder and converts them to RRD.
#
# REQUIREMENTS: works best with xml-migration-v01.sh and rrd2xml-convert-v01.sh
#
# CODE:
/bin/echo "What is the location of your RRD XML files? (example: /usr/local/pnp4nagios/var/perfdata)"
read xmldatadir
/usr/bin/yum install rrdtool -y
/bin/echo "Stopping Nagios and Apache service..."
/etc/init.d/nagios stop
/etc/init.d/httpd stop
/bin/find $xmldatadir -name \*.rrd.xml > rrdxmllist.txt
while read xmlrrd
do
        /bin/echo "Restoring $xmlrrd RRD file." >> xml2rrd-convert.log
        /bin/echo "Restoring $xmlrrd RRD file."
	/bin/rm -rf "${xmlrrd%.xml}"
        /usr/bin/rrdtool restore "$xmlrrd" "${xmlrrd%.xml}"  >> xml2rrd-convert.log
        /bin/echo "Deleting $xmlrrd XML file" >> xml2rrd-convert.log
        /bin/echo "Deleting $xmlrrd XML file"
	/bin/rm -rf $xmlrrd
done < rrdxmllist.txt
rm -rf rrdxmllist.txt
/bin/chown -R nagios:nagios $xmldatadir
/bin/echo "XML convert finished, check xml2rrd-convert.log for file list!"
/bin/echo "Starting Nagios and Apache service..."
/etc/init.d/nagios restart
/etc/init.d/httpd restart
