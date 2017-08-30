#!/bin/bash

mkdir -p /etc/systemd/system/flanneld.service.d
mkdir -p /etc/flannel

cat << EOF > /etc/flannel/options.env
FLANNELD_IFACE=${IP_ADDR}
FLANNELD_ETCD_ENDPOINTS=${ETCD_ENDPOINTS}
EOF

cat << EOF > /etc/sysconfig/flanneld
FLANNEL_OPTIONS="--iface=eth1 --ip-masq=true -v=3 $FLANNEL_OPTIONS"
FLANNEL_ETCD_ENDPOINTS="${ETCD_ENDPOINTS}"
FLANNEL_ETCD_PREFIX="/atomic.io/network"
EOF

cat << EOF > /etc/systemd/system/flanneld.service.d/40-ExecStartPre-symlink.conf
[Service]
ExecStartPre=/usr/bin/ln -sf /etc/flannel/options.env /run/flannel/options.env
EOF

mkdir -p /etc/systemd/system/docker.service.d
cat << EOF > /etc/systemd/system/docker.service.d/40-flannel.conf
[Unit]
Requires=flanneld.service
After=flanneld.service
[Service]
EnvironmentFile=/etc/kubernetes/cni/docker_opts_cni.env
EOF

mkdir -p /etc/kubernetes/cni/net.d

cat << EOF > /etc/kubernetes/cni/docker_opts_cni.env
DOCKER_OPT_BIP=""
DOCKER_OPT_IPMASQ=""
EOF

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