#!/bin/sh
# 
# linux-cluster-install-v01.sh (19 September 2013)
# GeekPeek.Net scripts - Install and Configure Linux Cluster on CentOS 6
#
# INFO: This script was tested on CentOS 6.4 minimal installation. Script first configures SSH Key Authentication between nodes.
# The script installs Corosync, Pacemaker and CRM Shell for Pacemaker management packages on both nodes. It creates default 
# Corosync configuration file and Authentication Key and transfers both to the second node. It configures Corosync and Pacemaker 
# to start at boot and starts the services on both nodes. It shows the current status of the Linux Cluster.
#
# CODE:
echo "Root SSH must be permited on the second Linux Cluster node. DNS resolution for Linux Cluster nodes must be properly configured!"
echo "NTP synchronization for both Linux Cluster nodes must also be configured!"
echo ""
echo "Are all of the above conditions satisfied? (y/n)"
read rootssh
case $rootssh in
	y)
                echo "Please enter the IP address of the first Linux Cluster node."
                read ipaddr1		
		echo "Please enter the IP address of the second Linux Cluster node."
		read ipaddr2
		echo ""
		echo "Generating SSH key..."
		/usr/bin/ssh-keygen
		echo ""
		echo "Copying SSH key to the second Linux Cluster node..."
		echo "Please enter the root password for the second Linux Cluster node."
		/usr/bin/ssh-copy-id root@$ipaddr2
		echo ""
		echo "SSH Key Authentication successfully set up ... continuing Linux Cluster package installation..."
		;;
	n)
		echo "Root access must be enabled on the second machine...exiting!"
		exit 1
		;;
	*)
		echo "Unknown choice ... exiting!"
		exit 2
esac
echo "[haclustering]" >> /etc/yum.repos.d/ha-clustering.repo
echo "name=HA Clustering" >> /etc/yum.repos.d/ha-clustering.repo
echo "baseurl=http://download.opensuse.org/repositories/network:/ha-clustering:/Stable/CentOS_CentOS-6/" >> /etc/yum.repos.d/ha-clustering.repo
echo "enabled=1" >> /etc/yum.repos.d/ha-clustering.repo
echo "gpgcheck=0" >> /etc/yum.repos.d/ha-clustering.repo
/usr/bin/scp /etc/yum.repos.d/ha-clustering.repo root@$ipaddr2:/etc/yum.repos.d/
/usr/bin/yum install pacemaker corosync crmsh -y
/usr/bin/ssh root@$ipaddr2 /usr/bin/yum install pacemaker corosync crmsh -y
/bin/rm /etc/yum.repos.d/ha-clustering.repo
/usr/bin/ssh root@$ipaddr2 /bin/rm /etc/yum.repos.d/ha-clustering.repo
echo ""
echo "Creating Corosync config file..."
echo ""
echo "compatibility: whitetank" >> /etc/corosync/corosync.conf
echo "" >> /etc/corosync/corosync.conf
echo "aisexec {" >> /etc/corosync/corosync.conf
echo "	# Run as root - this is necessary to be able to manage resources with Pacemaker" >> /etc/corosync/corosync.conf
echo "	user: root" >> /etc/corosync/corosync.conf
echo "	group: root" >> /etc/corosync/corosync.conf
echo "}" >> /etc/corosync/corosync.conf
echo "" >> /etc/corosync/corosync.conf
echo "service {" >> /etc/corosync/corosync.conf
echo "	# Load the Pacemaker Cluster Resource Manager" >> /etc/corosync/corosync.conf
echo "	ver: 1" >> /etc/corosync/corosync.conf
echo "	name: pacemaker" >> /etc/corosync/corosync.conf
echo "	use_mgmtd: no" >> /etc/corosync/corosync.conf
echo "	use_logd: no" >> /etc/corosync/corosync.conf
echo "}" >> /etc/corosync/corosync.conf
echo "" >> /etc/corosync/corosync.conf
echo "totem {" >> /etc/corosync/corosync.conf
echo "	version: 2" >> /etc/corosync/corosync.conf
echo "	#How long before declaring a token lost (ms)" >> /etc/corosync/corosync.conf
echo "		token: 5000" >> /etc/corosync/corosync.conf
echo "	# How many token retransmits before forming a new configuration" >> /etc/corosync/corosync.conf
echo "		token_retransmits_before_loss_const: 10" >> /etc/corosync/corosync.conf
echo "	# How long to wait for join messages in the membership protocol (ms)" >> /etc/corosync/corosync.conf
echo "		join: 1000" >> /etc/corosync/corosync.conf
echo "	# How long to wait for consensus to be achieved before starting a new" >> /etc/corosync/corosync.conf
echo "	# round of membership configuration (ms)" >> /etc/corosync/corosync.conf
echo "		consensus: 7500" >> /etc/corosync/corosync.conf
echo "	# Turn off the virtual synchrony filter" >> /etc/corosync/corosync.conf
echo "		vsftype: none" >> /etc/corosync/corosync.conf
echo "	# Number of messages that may be sent by one processor on receipt of the token" >> /etc/corosync/corosync.conf
echo "		max_messages: 20" >> /etc/corosync/corosync.conf
echo "	# Stagger sending the node join messages by 1..send_join ms" >> /etc/corosync/corosync.conf
echo "		send_join: 45" >> /etc/corosync/corosync.conf
echo "	# Limit generated nodeids to 31-bits (positive signed integers)" >> /etc/corosync/corosync.conf
echo "		clear_node_high_bit: yes" >> /etc/corosync/corosync.conf
echo "	# Disable encryption" >> /etc/corosync/corosync.conf
echo "		secauth: off" >> /etc/corosync/corosync.conf
echo "	# How many threads to use for encryption/decryption" >> /etc/corosync/corosync.conf
echo "		threads: 0" >> /etc/corosync/corosync.conf
echo "	# Optionally assign a fixed node id (integer)" >> /etc/corosync/corosync.conf
echo "	# nodeid: 1234interface {" >> /etc/corosync/corosync.conf
echo "" >> /etc/corosync/corosync.conf
echo "		interface {" >> /etc/corosync/corosync.conf
echo "			ringnumber: 0" >> /etc/corosync/corosync.conf
echo "			# The following values need to be set based on your environment" >> /etc/corosync/corosync.conf
echo "				bindnetaddr: $ipaddr2" >> /etc/corosync/corosync.conf
echo "				mcastaddr: 226.94.1.1" >> /etc/corosync/corosync.conf
echo "				mcastport: 5405" >> /etc/corosync/corosync.conf
echo "				ttl: 1" >> /etc/corosync/corosync.conf
echo "		}" >> /etc/corosync/corosync.conf
echo "	}" >> /etc/corosync/corosync.conf
echo "" >> /etc/corosync/corosync.conf
echo "logging {" >> /etc/corosync/corosync.conf
echo "	fileline: off" >> /etc/corosync/corosync.conf
echo "	to_stderr: no" >> /etc/corosync/corosync.conf
echo "	to_logfile: yes" >> /etc/corosync/corosync.conf
echo "	to_syslog: yes" >> /etc/corosync/corosync.conf
echo "	logfile: /var/log/cluster/corosync.log" >> /etc/corosync/corosync.conf
echo "	debug: off" >> /etc/corosync/corosync.conf
echo "	timestamp: on" >> /etc/corosync/corosync.conf
echo "" >> /etc/corosync/corosync.conf
echo "logger_subsys {" >> /etc/corosync/corosync.conf
echo "	subsys: AMF" >> /etc/corosync/corosync.conf
echo "	debug: off" >> /etc/corosync/corosync.conf
echo "	}" >> /etc/corosync/corosync.conf
echo "}" >> /etc/corosync/corosync.conf
echo "" >> /etc/corosync/corosync.conf
echo "amf {" >> /etc/corosync/corosync.conf
echo "	mode: disabled" >> /etc/corosync/corosync.conf
echo "}" >> /etc/corosync/corosync.conf
echo ""
echo "Corosync configuration file created, transferring config file so second Linux Cluster node..."
/usr/bin/scp /etc/corosync/corosync.conf root@$ipaddr2:/etc/corosync/
/bin/sed -i "s/bindnetaddr: $ipaddr2/bindnetaddr: $ipaddr1/g" /etc/corosync/corosync.conf
echo ""
echo "Creating Corosync secret key... This might take some time!"
/usr/sbin/corosync-keygen
/usr/bin/scp /etc/corosync/authkey root@$ipaddr2:/etc/corosync/
echo ""
echo "Starting services..."
echo ""
/etc/init.d/corosync start
/usr/bin/ssh root@$ipaddr2 /etc/init.d/corosync start
/etc/init.d/pacemaker start
/usr/bin/ssh root@$ipaddr2 /etc/init.d/pacemaker start
chkconfig corosync on
chkconfig pacemaker on
/usr/bin/ssh root@$ipaddr2 chkconfig corosync on
/usr/bin/ssh root@$ipaddr2 chkconfig pacemaker on
echo ""
echo "Waiting for cluster status..."
echo ""
sleep 10
echo "CLUSTER STATUS:"
/usr/sbin/crm status
echo ""
echo "Linux Cluster successfully installed and configured! You can now continue configuring your Cluster Resources!"
