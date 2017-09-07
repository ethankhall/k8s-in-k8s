#!/bin/bash

kube-apiserver \
    --requestheader-allowed-names=kubelet.k8s.com,kube-apiserver.k8s.com,admin.k8s.com \
    --service-cluster-ip-range=${SERVICE_CLUSTER} \
    --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname \
    --requestheader-username-headers=X-Remote-User \
    --requestheader-extra-headers-prefix=X-Remote-Extra- \
    --secure-port=6443 \
    --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds \
    --allow-privileged=true \
    --experimental-bootstrap-token-auth=true \
    --requestheader-group-headers=X-Remote-Group \
    --insecure-port=0 \
    --client-ca-file=/etc/kubernetes/pki/ca.pem \
    --tls-cert-file=/etc/kubernetes/pki/apiserver.pem \
    --kubelet-client-certificate=/etc/kubernetes/pki/worker.pem \
    --requestheader-client-ca-file=/etc/kubernetes/pki/worker.pem \
    --kubelet-client-key=/etc/kubernetes/pki/worker-key.pem \
    --tls-private-key-file=/etc/kubernetes/pki/apiserver-key.pem \
    --proxy-client-key-file=/etc/kubernetes/pki/worker-key.key \
    --service-account-key-file=/etc/kubernetes/pki/service-key.pem \
    --advertise-address=${IP_ADDR} \
    --etcd-servers=${ETCD_SERVERS} \
    --runtime-config=admissionregistration.k8s.io/v1alpha1 \
    --bind-address 0.0.0.0 \
    --v=2
    #--authorization-mode=RBAC,Node \