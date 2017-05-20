#!/bin/bash
. ./ovs-config.sh
# !! Just for Testing!!!
# Not use without testing !!
#
# Source: http://xmodulo.com/install-configure-kvm-open-vswitch-ubuntu-debian.html

echo "Install Packages for Debian OS"
apt-get install build-essential libssl-dev linux-headers-$(uname -r) 

#lsmod | grep openvswitch

echo " Create a skeleton OVS configuration database."
ovsdb-tool create /etc/openvswitch/conf.db ./vswitchd/vswitch.ovsschema


echo "Start OVS database server."

ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock - remote=db:Open_vSwitch,manager_options --pidfile --detach

echo "Initialize OVS configuration database."
ovs-vsctl --no-wait init 

echo "Finally, start OVS daemon."
ovs-vswitchd --pidfile --detach 

echo "user-mode Linux utilities install"
apt-get install uml-utilities 

echo "Create bridge startup scripts as follows"

echo "Create /etc/openvswitch/ovs-ifup file line peer line"

echo "#!/bin/sh" >> /etc/openvswitch/ovs-ifup 
echo "" >> /etc/openvswitch/ovs-ifup 
echo "switch='br0'" >> /etc/openvswitch/ovs-ifup 
echo "" >> /etc/openvswitch/ovs-ifup 
echo "/sbin/ifconfig $1 0.0.0.0 up" >> /etc/openvswitch/ovs-ifup 
echo "ovs-vsctl add-port ${switch} $1" >> /etc/openvswitch/ovs-ifup 

echo "Create /etc/openvswitch/ovs-ifdown file line peer line"

echo "#!/bin/sh" >> /etc/openvswitch/ovs-ifdown
echo "" >> /etc/openvswitch/ovs-ifdown
echo "switch='br0'" >> /etc/openvswitch/ovs-ifdown
echo "/sbin/ifconfig $1 0.0.0.0 down" >> /etc/openvswitch/ovs-ifdown
echo "ovs-vsctl del-port ${switch} $1" >> /etc/openvswitch/ovs-ifdown

echo "Make the '/etc/openvswitch/ovs-if*' executable "
chmod +x /etc/openvswitch/ovs-if* 

echo "Configure with ovs-vsctl your networking"
echo "Primary Interface is : $PRI_INT"
echo "The name of the networkbridge is : $BRIDGE_INT "
echo "Add the Port : $NEW_PORT"

sleep 3

ovs-vsctl add-br $BRIDGE_INT
ovs-vsctl add-port $BRIDGE_INT $NEW_PORT

