#!/bin/bash
# !! Just for Testing!!!
# Not use
#
# Source: http://xmodulo.com/install-configure-kvm-open-vswitch-ubuntu-debian.html

apt-get install build-essential libssl-dev linux-headers-$(uname -r) 

#lsmod | grep openvswitch

# Create a skeleton OVS configuration database.
ovsdb-tool create /etc/openvswitch/conf.db ./vswitchd/vswitch.ovsschema


#Start OVS database server.

ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock - remote=db:Open_vSwitch,manager_options --pidfile --detach

# Initialize OVS configuration database.
ovs-vsctl --no-wait init 

# Finally, start OVS daemon.
ovs-vswitchd --pidfile --detach 

#user-mode Linux utilities install
apt-get install uml-utilities 

# Create bridge startup scripts as follows


echo "#!/bin/sh" >> /etc/openvswitch/ovs-ifup 
echo "" >> /etc/openvswitch/ovs-ifup 
echo "switch='br0'" >> /etc/openvswitch/ovs-ifup 
echo "" >> /etc/openvswitch/ovs-ifup 
echo "/sbin/ifconfig $1 0.0.0.0 up" >> /etc/openvswitch/ovs-ifup 
echo "ovs-vsctl add-port ${switch} $1" >> /etc/openvswitch/ovs-ifup 

echo "#!/bin/sh" >> /etc/openvswitch/ovs-ifdown
echo "" >> /etc/openvswitch/ovs-ifdown
echo "switch='br0'" >> /etc/openvswitch/ovs-ifdown
echo "/sbin/ifconfig $1 0.0.0.0 down" >> /etc/openvswitch/ovs-ifdown
echo "ovs-vsctl del-port ${switch} $1" >> /etc/openvswitch/ovs-ifdown

chmod +x /etc/openvswitch/ovs-if* 

ovs-vsctl add-br br0
ovs-vsctl add-port br0 eth5

