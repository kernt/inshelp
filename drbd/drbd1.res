resource r0 {
 
# Taux de transfert
# 10M pour du 100mbits
# 100M pour du 1Gbits
syncer {
rate 10M;
}
 
on node1 {
device /dev/drbd0;
disk /dev/sdb1;
address 192.168.10.128:7788;
meta-disk internal;
}
on node2 {
device /dev/drbd0;
disk /dev/sdb1;
address 192.168.10.129:7788;
meta-disk internal;
}
}
