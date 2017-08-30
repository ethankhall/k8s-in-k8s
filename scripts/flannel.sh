#!/bin/bash

mkdir -p /etc/systemd/system/flanneld.service.d

cat << EOF > /etc/sysconfig/flanneld
FLANNEL_OPTIONS="--iface=eth1 -v=3 $FLANNEL_OPTIONS"
FLANNEL_ETCD_ENDPOINTS="${ETCD_ENDPOINTS}"
FLANNEL_ETCD_PREFIX="/atomic.io/network"
EOF

mkdir -p /etc/systemd/system/docker.service.d
cat << EOF > /etc/systemd/system/docker.service.d/40-flannel.conf
[Unit]
Requires=flanneld.service
After=flanneld.service
[Service]
EnvironmentFile=/run/flannel/docker
EOF

mkdir -p /etc/kubernetes/cni/net.d
cat << EOF > /etc/kubernetes/cni/net.d/10-flannel.conf
{
    "name": "podnet",
    "type": "flannel",
    "delegate": {
        "isDefaultGateway": true
    }
}
EOF

systemctl daemon-reload
systemctl restart flanneld
systemctl enable flanneld

systemctl restart docker