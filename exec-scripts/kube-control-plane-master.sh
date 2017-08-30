#!/bin/bash -e

mkdir -p /etc/kubernetes/manifests

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
    volumeMounts:
      - mountPath: /etc/kubernetes/cni
        name: cni
      - mountPath: /etc/kubernetes/pki
        name: certs
      - mountPath: /var/run/dbus
        name: dbus-sock
    env:
      - name: MASTER_URL
        value: ${MASTER_URL}
      - name: POD_NETWORK
        value: ${POD_NETWORK}
    securityContext:
      privileged: true
  volumes:
    - name: cni
      hostPath:
        # directory location on host
        path: /etc/kubernetes/cni
    - name: certs
      hostPath:
        # directory location on host
        path: /etc/kubernetes/pki
    - name: dbus-sock
      hostPath:
        path: /var/run/dbus
EOF

cat <<EOF > /etc/kubernetes/kubelet.conf
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

dmsetup mknodes

# First, make sure that cgroups are mounted correctly.
CGROUP=/sys/fs/cgroup
: {LOG:=stdio}

[ -d $CGROUP ] ||
	mkdir $CGROUP

mountpoint -q $CGROUP ||
	mount -n -t tmpfs -o uid=0,gid=0,mode=0755 cgroup $CGROUP || {
		echo "Could not make a tmpfs mount. Did you use --privileged?"
		exit 1
	}

if [ -d /sys/kernel/security ] && ! mountpoint -q /sys/kernel/security
then
    mount -t securityfs none /sys/kernel/security || {
        echo "Could not mount /sys/kernel/security."
        echo "AppArmor detection and --privileged mode might break."
    }
fi

/usr/bin/kubelet \
  --pod-infra-container-image=gcr.io/google_containers/pause-amd64:3.0 \
  --kubeconfig=/etc/kubernetes/kubelet.conf \
  --register-node \
  --require-kubeconfig=true \
  --pod-manifest-path=/etc/kubernetes/manifests \
  --allow-privileged=true \
  --network-plugin=cni \
  --cni-conf-dir=/etc/kubernetes/cni/net.d \
  --cluster-dns=10.96.0.10 \
  --cluster-domain=cluster.local \
  --authorization-mode=Webhook \
  --client-ca-file=/etc/kubernetes/pki/ca.pem \
  --tls-cert-file=/etc/kubernetes/pki/worker.pem \
  --tls-private-key-file=/etc/kubernetes/pki/worker-key.pem \
  --cadvisor-port=0 \
  --hostname-override=${NAME} \
  --v=2