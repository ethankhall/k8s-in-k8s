#!/bin/bash

cat <<EOF > /etc/kubernetes/kubeconfig
apiVersion: v1
kind: Config
clusters:
  - cluster:
      certificate-authority: /etc/kubernetes/pki/ca.pem
      server: https://${MASTER_IP}:6443
    name: kubernetes
contexts:
  - context:
      cluster: kubernetes
      user: kube-controller
    name: kube-controller-to-kubernetes
current-context: kube-controller-to-kubernetes
users:
  - name: kube-controller
    user:
      client-certificate: /etc/kubernetes/pki/worker.pem
      client-key: /etc/kubernetes/pki/worker-key.pem
EOF

/usr/bin/kube-controller-manager \
  --address=0.0.0.0 \
  --allocate-node-cidrs=false \
  --cluster-name=kubernetes \
  --leader-elect=true \
  --kubeconfig /etc/kubernetes/kubeconfig
  --service-cluster-ip-range=10.32.0.0/16 \
  --v=2