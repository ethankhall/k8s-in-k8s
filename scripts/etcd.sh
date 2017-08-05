#!/bin/bash

cat << EOF >/etc/systemd/system/etcd.service
[Service]
Environment="RKT_RUN_ARGS=--uuid-file-save=/var/run/etcd-pod.uuid"
ExecStartPre=-/usr/bin/rkt rm --uuid-file=/var/run/etcd-pod.uuid
ExecStart=/usr/bin/rkt run quay.io/ethankhall/etcd:latest \
    --environment=MY_IP=172.17.4.100 --environment=INITAL_CLUSTER=etcd0=http://172.17.4.100:2380 \
    --port=port-2380:2380 --port=port-2379:2379
ExecStop=-/usr/bin/rkt stop --uuid-file=/var/run/etcd-pod.uuid
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl restart etcd
systemctl enable etcd

sleep 3

curl -X PUT -d "value={\"Network\":\"10.2.0.0/16\",\"Backend\":{\"Type\":\"vxlan\"}}" "http://localhost:2379/v2/keys/atomic.io/network/config"