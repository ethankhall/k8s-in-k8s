#!/bin/bash

cat << EOF >/etc/systemd/system/kube-api-server.service
[Service]
ExecStartPre=-/usr/bin/rkt rm --uuid-file=/var/run/kube-api-server-pod.uuid
ExecStart=/usr/bin/rkt run \
    ${REPO}/kube-api-server:latest \
    --uuid-file-save=/var/run/kube-api-server-pod.uuid \
    --environment=ETCD_SERVERS=${ETCD_ENDPOINTS} --environment=IP_ADDR=${IP_ADDR} \
    --port=port-6443:6443 \
    --mount volume=k8s-cert,target=/etc/kubernetes/pki \
    --volume=k8s-cert,kind=host,source=/etc/kubernetes/pki,readOnly=true
ExecStop=-/usr/bin/rkt stop --uuid-file=/var/run/kube-api-server-pod.uuid
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

cat << EOF >/etc/systemd/system/kube-controller-manager.service
[Service]
ExecStartPre=-/usr/bin/rkt rm --uuid-file=/var/run/kube-controller-manager-pod.uuid
ExecStart=/usr/bin/rkt run \
    ${REPO}/kube-controller-manager:latest \
    --uuid-file-save=/var/run/kube-controller-manager-pod.uuid \
    --environment=MASTER_URL=https://${IP_ADDR}:6443 \
    --mount volume=k8s-cert,target=/etc/kubernetes/pki \
    --volume=k8s-cert,kind=host,source=/etc/kubernetes/pki,readOnly=true
ExecStop=-/usr/bin/rkt stop --uuid-file=/var/run/kube-controller-manager-pod.uuid
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

cat << EOF >/etc/systemd/system/kube-scheduler.service
[Service]
ExecStartPre=-/usr/bin/rkt rm --uuid-file=/var/run/kube-scheduler-pod.uuid
ExecStart=/usr/bin/rkt run \
    ${REPO}/kube-scheduler:latest \
    --uuid-file-save=/var/run/kube-scheduler-pod.uuid \
    --environment=ETCD_SERVERS=${ETCD_ENDPOINTS} \
    --environment=MASTER_URL=https://${IP_ADDR}:6443 \
    --port=port-10251:10251 \
    --mount volume=k8s-cert,target=/etc/kubernetes/pki \
    --volume=k8s-cert,kind=host,source=/etc/kubernetes/pki,readOnly=true
ExecStop=-/usr/bin/rkt stop --uuid-file=/var/run/kube-scheduler-pod.uuid
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /etc/kubernetes/pki
cp /vagrant/certs/${IP_ADDR}/*.pem /etc/kubernetes/pki

systemctl daemon-reload

rkt fetch ${REPO}/kube-api-server:latest
systemctl restart kube-api-server
systemctl enable kube-api-server

rkt fetch ${REPO}/kube-controller-manager:latest
systemctl restart kube-controller-manager
systemctl enable kube-controller-manager

rkt fetch ${REPO}/kube-scheduler:latest
systemctl restart kube-scheduler
systemctl enable kube-scheduler