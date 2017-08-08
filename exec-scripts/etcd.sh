#!/bin/sh

mkdir /data

/usr/local/bin/etcd \
  --name ${NODE_NAME} \
  --initial-advertise-peer-urls http://${MY_IP}:2380 \
  --listen-peer-urls http://0.0.0.0:2380 \
  --listen-client-urls ${LISTEN_CLIENTS} \
  --advertise-client-urls http://${MY_IP}:2379 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-cluster ${INITAL_CLUSTER} \
  --initial-cluster-state new \
  --data-dir /data