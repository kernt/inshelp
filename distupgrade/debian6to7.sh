#

DEBAINVER="cat /etc/debian_version"
KERNELVER"dpkg -l | grep linux-image"
KERNELRELEASE="uname -r"

apt-get update
apt-get upgrade
apt-get dist-upgrade

#überall das Wort “squeeze” auf “wheezy” umgeschrieben

# sed 

echo "Folgende Kernel sind Installiert $KERNELVER"
echo "Folgender Kernel leuft $KERNELRELEASE"

apt-get update

apt-get install udev

echo "dist-upgrade wird vorgeneommen"

apt-get dist-upgrade

echo "$DEBAINVER wurde eingerichtet"

echo "Bitte den Rechner neu Starten"

exit 0

