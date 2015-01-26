useradd -m -s /bin/bash adminuse
passwd adminuser
smbpasswd -a adminuser
usermod -aG opsiadmin adminuser
getent group opsiadmin
usermod -aG pcpatch adminuser
grep pcpatch /etc/group
sleep 4
opsi-setup --patch-sudoers-file
