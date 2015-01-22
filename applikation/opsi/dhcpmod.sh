aptitude install isc-dhcp-server
opsi-setup --auto-configure-dhcpd
echo "
backend_.* : file, opsipxeconfd, dhcpd
host_.*    : file, opsipxeconfd, dhcpd
" >> /etc/opsi/backendManager/dispatch.conf

opsiconfupdate # Note: include func_opsi.sh

