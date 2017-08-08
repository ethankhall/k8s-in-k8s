#!/bin/bash

mkdir -p /opt/etcd/data

cat << EOF >/etc/systemd/system/etcd.service
[Service]
ExecStartPre=-/usr/bin/rkt rm --uuid-file=/var/run/etcd-pod.uuid
ExecStart=/usr/bin/rkt run \
    ${REPO}/etcd:latest \
    --volume=etcd-data,kind=host,source=/opt/etcd/data,readOnly=false \
    --uuid-file-save=/var/run/etcd-pod.uuid \
    --environment=MY_IP=172.17.4.100 \
    --environment=INITAL_CLUSTER=etcd0=http://172.17.4.100:2380 \
    --mount volume=etcd-data,target=/data \
    --port=port-2380:2380 \
    --port=port-2379:2379
ExecStop=-/usr/bin/rkt stop --uuid-file=/var/run/etcd-pod.uuid
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

rkt fetch ${REPO}/etcd:latest

systemctl daemon-reload
systemctl restart etcd
systemctl enable etcd

curl -X PUT -d "value={\"Network\":\"10.2.0.0/16\",\"Backend\":{\"Type\":\"vxlan\"}}" "http://localhost:2379/v2/keys/atomic.io/network/config"

while ! rkt status $(cat /var/run/etcd-pod.uuid) | grep state=running; do 
    echo "Waiting for etcd..."
    sleep 10;
done