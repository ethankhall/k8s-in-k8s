#!/bin/bash

cat <<EOF > /etc/kubernetes/kube-proxy.kubeconfig
apiVersion: v1
kind: Config
clusters:
  - cluster:
      certificate-authority: /etc/kubernetes/pki/ca.pem
      server: ${MASTER_URL}
    name: kubernetes
contexts:
  - context:
      cluster: kubernetes
      user: proxy
    name: proxy-to-kubernetes
current-context: proxy-to-kubernetes
users:
  - name: proxy
    user:
      client-certificate: /etc/kubernetes/pki/worker.pem
      client-key: /etc/kubernetes/pki/worker-key.pem
EOF

/usr/bin/kube-proxy \
    --cluster-cidr=10.200.0.0/16 \
    --masquerade-all=true \
    --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig \
    --proxy-mode=iptables \
    --v=2