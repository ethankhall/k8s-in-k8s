#!/bin/bash
yum install -y systemd-networkd systemd-resolved

mkdir -p /etc/systemd/network

cat << EOF > /etc/systemd/network/20-dhcp.network
[Match]
Name=eth0

[Network]
DHCP=yes
EOF

cat << EOF > /etc/systemd/network/10-static-eth1.network
[Match]
Name=eth1

[Network]
Address=${IP_ADDR}/24

[Route]
Gateway=172.17.4.1
Destination=172.17.4.0/24
EOF

systemctl daemon-reload

systemctl disable NetworkManager
systemctl enable systemd-networkd

systemctl enable systemd-resolved
systemctl start systemd-resolved

/usr/bin/rm /etc/resolv.conf
/usr/bin/ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

systemctl stop NetworkManager
systemctl restart systemd-networkd