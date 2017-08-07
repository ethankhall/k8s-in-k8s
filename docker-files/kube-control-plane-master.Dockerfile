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
    apk add --no-cache docker curl bash coreutils kubernetes && \
    mkdir /etc/kubernetes && \
    mkdir /etc/kubernetes/pki

ENV MASTER_URL "https://127.0.0.1:6443"
ENV ETCD_SERVERS "http://127.0.0.1:2379"
EXPOSE 10251

COPY exec-scripts/kube-control-plane-master.sh /kube-control-plane-master.sh
COPY certs/ca.pem certs/worker.pem certs/worker-key.pem /etc/kubernetes/pki/
ENTRYPOINT /kube-control-plane-master.sh