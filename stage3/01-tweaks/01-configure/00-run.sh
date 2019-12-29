#!/bin/bash -e

install -m 644 files/tmconfig.txt "${ROOTFS_DIR}/boot/"

on_chroot <<EOF
wget -qO - http://debian.fhem.de/archive.key | apt-key add -
echo "deb http://debian.fhem.de/nightly/ /" > /etc/apt/sources.list.d/fhem.list
apt-get update
apt-get install fhem autossh
useradd -s /usr/sbin/nologin -m sshtunnel
. /boot/tmconfig.txt
ssh-keyscan -H -t rsa $AUTOSSHSERVER | tee >> /home/sshtunnel/.ssh/known_hosts                                                                                                                        
chown sshtunnel:sshtunnel /home/sshtunnel/.ssh/known_hosts
sed -i '/exit 0/d' /etc/rc.local
echo ". /boot/tmconfig.txt" >> /etc/rc.local
echo "su -s /bin/sh sshtunnel -c \"autossh -f -i /boot/tunnel_key \$AUTOSSHSERVER -N -R \$AUTOSSHSERVER:\$PORT1:localhost:22\"" >> /etc/rc.local
echo "su -s /bin/sh sshtunnel -c \"autossh -f -i /boot/tunnel_key \$AUTOSSHSERVER -N -R \$AUTOSSHSERVER:\$PORT2:localhost:8083\"" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local
EOF

