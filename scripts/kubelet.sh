#!/bin/bash

cat << EOF > /etc/systemd/system/kubelet.service
[Service]
ExecStartPre=-/usr/bin/rkt rm --uuid-file=/var/run/kubelet-pod.uuid
ExecStart=/usr/bin/rkt run \
    --volume=system-run,kind=host,source=/var/run,readOnly=false \
    --volume=k8s-cert,kind=host,source=/etc/kubernetes/pki,readOnly=true \
    --volume=k8s-cni,kind=host,source=/etc/kubernetes/cni,readOnly=true \
    --volume=docker-lib,kind=host,source=/var/lib/docker,readOnly=false \
    --volume=kubelet-lib,kind=host,source=/var/lib/kubelet,readOnly=false,recursive=true \
    --volume=flannel-run,kind=host,source=/run/flannel,readOnly=false \
    --volume dns,kind=host,source=/etc/resolv.conf \
    ${REPO}/kubelet:latest \
    --uuid-file-save=/var/run/kube-api-server-pod.uuid \
    --environment=ETCD_SERVERS=${ETCD_ENDPOINTS} \
    --environment=MASTER_URL=${MASTER_URL} \
    --environment=REPO=${REPO}/ \
    --environment=NAME=${HOST_NAME} \
    --environment=VERBOSE_LEVEL=2 \
    --environment=POD_NETWORK=${POD_NETWORK} \
    --mount volume=system-run,target=/var/run \
    --mount volume=dns,target=/etc/resolv.conf \
    --mount volume=k8s-cert,target=/etc/kubernetes/pki \
    --mount volume=k8s-cni,target=/etc/kubernetes/cni \
    --mount volume=docker-lib,target=/var/lib/docker \
    --mount volume=flannel-run,target=/run/flannel \
    --mount volume=kubelet-lib,target=/var/lib/kubelet \
    --caps-retain=CAP_FOWNER,CAP_SYS_ADMIN,CAP_NET_ADMIN \
    --stage1-from-dir=stage1-fly.aci \
    --port=port-10248:10248
ExecStop=-/usr/bin/rkt stop --uuid-file=/var/run/kubelet-pod.uuid
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /var/lib/kubelet

systemctl daemon-reload

rkt fetch ${REPO}/kubelet:latest
systemctl restart kubelet
systemctl enable kubelet