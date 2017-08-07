#!/bin/bash -e

cat << EOF > /etc/kubernetes/manifests/kube-proxy.yaml
apiVersion: v1
kind: Pod
metadata:
  name: kube-proxy
  namespace: kube-system
spec:
  hostNetwork: true
  containers:
  - name: kube-proxy
    image: ${REPO}kube-proxy
    env:
      - name: MASTER_IP
        value: ${MASTER_IP}
    securityContext:
      privileged: true
EOF

cat <<EOF > /etc/kubernetes/kubelet.conf
apiVersion: v1
clusters:
- cluster:
      certificate-authority: /etc/kubernetes/pki/ca.pem
      server: ${MASTER_URL}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubelet-csr
  name: kubelet-csr
- context:
    cluster: kubernetes
    user: tls-bootstrap-token-user
  name: tls-bootstrap-token-user@kubernetes
current-context: kubelet-csr
kind: Config
preferences: {}
users:
- name: kubelet-csr
  user:
    client-certificate: /etc/kubernetes/pki/worker.pem
    client-key: /etc/kubernetes/pki/worker-key.pem
- name: tls-bootstrap-token-user
  user:
    token: e68ed6.b92b1770093fdf0b
EOF

/usr/bin/kubelet \
  --pod-infra-container-image=gcr.io/google_containers/pause-amd64:3.0 \
  --kubeconfig=/etc/kubernetes/kubelet.conf \
  --require-kubeconfig=true \
  --pod-manifest-path=/etc/kubernetes/manifests \
  --allow-privileged=true \
  --network-plugin=cni \
  --cni-conf-dir=/etc/cni/net.d \
  --cni-bin-dir=/opt/cni/bin \
  --cluster-dns=10.96.0.10 \
  --cluster-domain=cluster.local \
  --authorization-mode=Webhook \
  --client-ca-file=/etc/kubernetes/pki/ca.pem \
  --cadvisor-port=0 \
  --cgroup-driver=cgroupfs