#!/bin/bash

cat << EOF >/etc/systemd/system/kube-control-plane-master.service
[Service]
ExecStartPre=-/usr/bin/rkt rm --uuid-file=/var/run/kube-control-plane-master-pod.uuid
ExecStart=/usr/bin/rkt run \
    --volume=system-run,kind=host,source=/var/run,readOnly=false \
    --volume=k8s-cert,kind=host,source=/etc/kubernetes/pki,readOnly=true \
    --volume=k8s-cni,kind=host,source=/etc/kubernetes/cni,readOnly=true \
    --volume dns,kind=host,source=/etc/resolv.conf \
    ${REPO}/kube-control-plane-master:latest \
    --uuid-file-save=/var/run/kube-api-server-pod.uuid \
    --environment=ETCD_SERVERS=${ETCD_ENDPOINTS} --environment=MASTER_URL=https://${IP_ADDR}:6443 \
    --environment=REPO=${REPO}/ \
    --mount volume=system-run,target=/var/run \
    --mount volume=dns,target=/etc/resolv.conf \
    --mount volume=k8s-cert,target=/etc/kubernetes/pki \
    --mount volume=k8s-cni,target=/etc/kubernetes/cni \
    --caps-retain=CAP_FOWNER,CAP_SYS_ADMIN \
    --stage1-from-dir=stage1-fly.aci \
    --net=host
ExecStop=-/usr/bin/rkt stop --uuid-file=/var/run/kube-control-plane-master-pod.uuid
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

rkt fetch ${REPO}/kube-control-plane-master:latest
systemctl restart kube-control-plane-master
systemctl enable kube-control-plane-master