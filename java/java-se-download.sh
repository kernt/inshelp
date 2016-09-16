#!/bin/bash 
#
#
# Source :  http://stackoverflow.com/questions/10268583/downloading-java-jdk-on-linux-via-wget-is-shown-license-page-instead
# example Link: http://www.oracle.com/technetwork/java/javase/downloads/java-archive-javase8-2177648.html#jre-8u65-oth-JPR

JAVASE-VER="jdk-8u65"


wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/${JAVASE-VER}-b14/jdk-${JAVASE-VER}-linux-x64.rpm

exit 0

