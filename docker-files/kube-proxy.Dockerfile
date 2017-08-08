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
    apk add --no-cache curl bash coreutils kubernetes iptables ip6tables && \
    mkdir /etc/kubernetes && \
    mkdir /etc/kubernetes/pki && \
    rm /usr/bin/hyperkube /usr/bin/kube-apiserver /usr/bin/kubelet \
        /usr/bin/kube-controller-manager /usr/bin/kube-scheduler /usr/bin/kubectl \
        /usr/bin/kubefed /usr/bin/kubeadm /usr/bin/kube-aggregator

ARG ROOT_CA_IP
ENV MASTER_URL "https://127.0.0.1:6443"

COPY exec-scripts/kube-proxy.sh /kube-proxy.sh
COPY ["certs/$ROOT_CA_IP/ca.pem", "certs/$ROOT_CA_IP/worker.pem", \
    "certs/$ROOT_CA_IP/worker-key.pem", "/etc/kubernetes/pki/"]"

ENTRYPOINT /kube-proxy.sh