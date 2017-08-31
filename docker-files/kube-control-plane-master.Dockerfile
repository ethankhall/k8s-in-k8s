FROM alpine:3.6

RUN echo "http://dl-1.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-1.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "http://dl-2.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-2.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "http://dl-3.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-3.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "http://dl-5.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-5.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache docker curl bash coreutils kubernetes device-mapper util-linux binutils findutils grep && \
    mkdir /etc/kubernetes && \
    mkdir /etc/kubernetes/pki &&  \
    rm /usr/bin/hyperkube /usr/bin/kube-apiserver \
        /usr/bin/kube-controller-manager /usr/bin/kube-scheduler /usr/bin/kubectl \
        /usr/bin/kubefed /usr/bin/kubeadm /usr/bin/kube-proxy /usr/bin/kube-aggregator && \
    mkdir -p /opt/cni/bin && \
    curl -L https://github.com/containernetworking/cni/releases/download/v0.6.0/cni-amd64-v0.6.0.tgz | tar xvz -C /opt/cni/bin && \
    curl -L https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-v0.6.0.tgz | tar xvz -C /opt/cni/bin

ARG ROOT_CA_IP
ENV REPO ""
ENV MASTER_URL "https://127.0.0.1:6443"
ENV ETCD_SERVERS "http://127.0.0.1:2379"
ENV VERBOSE_LEVEL 2
EXPOSE 10248

COPY exec-scripts/kube-control-plane-master.sh /kube-control-plane-master.sh
COPY ["certs/$ROOT_CA_IP/ca.pem", "certs/$ROOT_CA_IP/worker.pem", \
    "certs/$ROOT_CA_IP/worker-key.pem", "/etc/kubernetes/pki/"]"

ENTRYPOINT /kube-control-plane-master.sh