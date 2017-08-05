FROM quay.io/coreos/etcd:v3.2

ENV MY_IP "127.0.0.1"
ENV LISTEN_CLIENTS "http://0.0.0.0:2379"
ENV INITAL_CLUSTER "etcd0=http://127.0.0.1:2380"
ENV NODE_NAME "etcd0"

EXPOSE 2380
EXPOSE 2379

COPY exec-scripts/etcd.sh /etcd.sh

ENTRYPOINT /etcd.sh
