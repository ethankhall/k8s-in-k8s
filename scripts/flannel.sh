#!/bin/bash

mkdir -p /etc/systemd/system/flanneld.service.d

cat << EOF > /etc/sysconfig/flanneld
FLANNEL_IFACE="${IP_ADDR}"
FLANNEL_ETCD_ENDPOINTS="${ETCD_ENDPOINTS}"
FLANNEL_ETCD_PREFIX="/atomic.io/network"
EOF

mkdir -p /etc/systemd/system/docker.service.d
cat << EOF > /etc/systemd/system/docker.service.d/40-flannel.conf
[Unit]
Requires=flanneld.service
After=flanneld.service
[Service]
EnvironmentFile=/etc/kubernetes/cni/docker_opts_cni.env
EOF

mkdir -p /etc/kubernetes/cni
cat << EOF > /etc/kubernetes/cni/docker_opts_cni.env
DOCKER_OPT_BIP=""
DOCKER_OPT_IPMASQ=""
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