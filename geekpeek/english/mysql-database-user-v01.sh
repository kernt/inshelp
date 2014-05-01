#!/bin/sh
# 
# mysql-database-user-v01.sh (18 August 2013)
# GeekPeek.Net scripts - MySQL Create Database and User
#
# INFO: This script was created and tested on fresh CentOS 6.4 minimal installation. You can use this script to connect
# to MySQL instance and see existing databases, create new MySQL database, create new MySQL user, grant all privileges
# on desired database to desired user and delete/drop the desired database. With easy numbered choice menu, you can choose 
# what you want to do.
#
# CODE:
scriptloop="y"
while [ "$scriptloop" = "y" ]; do
/bin/echo "MYSQL SCRIPT MENU:"
/bin/echo ""
/bin/echo "1 - Connect to MySQL instance and see existing databases"
/bin/echo "2 - Create a new MySQL database"
/bin/echo "3 - Create a new MySQL user"
/bin/echo "4 - Grant ALL privileges on desired database to desired user"
/bin/echo "5 - Delete (drop) database"
/bin/echo ""
/bin/echo "q - EXIT MYSQL SCRIPT!"
/bin/echo ""
/bin/echo "Please enter NUMBER of choice (example: 3):"
read choice
case $choice in
1)
	if [ -z "$rootpasswd" ]; then
	/bin/echo "Please enter MySQL root user password!"
	read rootpasswd
	fi
	/usr/bin/mysql -uroot -p$rootpasswd -e "show databases;"
	;;
2)
        if [ -z "$rootpasswd" ]; then
        /bin/echo "Please enter MySQL root user password!"
        read rootpasswd
	fi
	/bin/echo "Please enter the NAME of the new database! (example: database1)"
	read dbname
	/bin/echo "Please enter the new database CHARACTER SET! (example: latin1, utf8, ...)"
	read charset
	/bin/echo "Creating new database..."
        /usr/bin/mysql -uroot -p$rootpasswd -e "CREATE DATABASE $dbname /*\!40100 DEFAULT CHARACTER SET $charset */;"
	/bin/echo "Database created!"
	/usr/bin/mysql -uroot -p$rootpasswd -e "show databases;"
        ;;
3)
        if [ -z "$rootpasswd" ]; then
        /bin/echo "Please enter MySQL root user password!"
        read rootpasswd
	fi
	/bin/echo "Please enter the NAME of the new user! (example: user1)"
	read username
	/bin/echo "Please enter the PASSWORD for the new user!"
	read userpass
	/bin/echo "Creating new user..."
        /usr/bin/mysql -uroot -p$rootpasswd -e "CREATE USER $username@localhost IDENTIFIED BY '$userpass';"
	/bin/echo "User created!"
	;;
4)
        if [ -z "$rootpasswd" ]; then
        /bin/echo "Please enter MySQL root user password!"
        read rootpasswd
	fi
        /bin/echo "Please enter the name of the DATABASE you are setting privileges on! (example: database1)"
        read database
        /bin/echo "Please enter the name of the USER you are giving privileges to! (example: user1)"
        read user
	/bin/echo "Granting ALL privileges on $database to $user!"
        /usr/bin/mysql -uroot -p$rootpasswd -e "GRANT ALL PRIVILEGES ON $database.* TO '$user'@'localhost';"
	/usr/bin/mysql -uroot -p$rootpasswd -e "FLUSH PRIVILEGES;"
	;;
5)
        if [ -z "$rootpasswd" ]; then
        /bin/echo "Please enter MySQL root user password!"
        read rootpasswd
        fi
	/bin/echo "Listing existing databases..."
        /usr/bin/mysql -uroot -p$rootpasswd -e "show databases;"
        /bin/echo "Please enter the name of the DATABASE you want to DELETE/DROP! (example: database1)"
        read database
        /usr/bin/mysql -uroot -p$rootpasswd -e "drop database $database;"
	;;
q)
	scriptloop="n"
	;;
*)
	/bin/echo "Unknown choice! Exiting..."
	;;
esac
done
