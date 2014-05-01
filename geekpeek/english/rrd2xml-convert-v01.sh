#!/bin/sh
# 
# rrd2xml-convert-v01.sh (5 June 2013)
# GeekPeek.Net scripts - RRD2XML convert script
#
# INFO: This script was created and tested on fresh CentOS 6.4 minimal installation. The script installs 
# RRDTool and dependencies. It creates a list of RRD files from selected folder and converts them to XML
# - makes it suitable for transfer to a different architecture (i386 -> x86_64).
#
# REQUIREMENTS: works best with xml-migration-v01.sh and xml2rrd-convert-v01.sh
#
# CODE:
/bin/echo "What is the location of your RRD files? (example: /usr/local/pnp4nagios/var/perfdata)"
read perfdatadir
/bin/echo "Installing RRDTool..."
/usr/bin/yum install rrdtool -y
echo "Searching for .rrd files ..."
/bin/find $perfdatadir -name \*.rrd > rrdfilelist.txt
/bin/echo "Converting .rrd to .xml ..."
while read line
do
        /bin/echo "Dumping $line to XML file." >> rrd2xml-convert.log
        /bin/echo "Dumping $line to XML file."
        /usr/bin/rrdtool dump $line $line.xml
done < rrdfilelist.txt
rm -rf rrdfilelist.txt
/bin/echo "RRD convert finished, check rrd2xml-convert.log for file list!"
