resource r0 {
 
startup {
wfc-timeout 30;
degr-wfc-timeout 15;
}
 
disk {
on-io-error detach;
}
 
# Taux de transfert
# 10M pour du 100mbits
# 100M pour du 1Gbits
syncer {
rate 100M;
}
 
on node1 {
device /dev/drbd0;
disk /dev/sdb1;
address 192.168.2.55:7788;
meta-disk internal;
}
on node2 {
device /dev/drbd0;
disk /dev/sdb1;
address 192.168.2.56:7788;
meta-disk internal;
}
}
