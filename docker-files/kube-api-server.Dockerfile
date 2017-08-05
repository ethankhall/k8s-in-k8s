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

ENV IP_ADDR "127.0.0.1"
ENV ETCD_SERVERS "http://127.0.0.1:2379"
EXPOSE 6443

COPY exec-scripts/apiserver.sh /apiserver.sh
COPY certs/ca.pem certs/apiserver.pem certs/worker.pem \
    certs/worker.pem certs/worker-key.pem certs/apiserver-key.pem \
    certs/ca-key.pem /etc/kubernetes/pki/
ENTRYPOINT /apiserver.sh