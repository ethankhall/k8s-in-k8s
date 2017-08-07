#!/bin/bash

cat <<EOF > /etc/kubernetes/kube-scheduler.kubeconfig
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

/usr/bin/kube-scheduler \
  --leader-elect=true \
  --kubeconfig /etc/kubernetes/kube-scheduler.kubeconfig \
  --master=${MASTER_URL} \
  --v=2