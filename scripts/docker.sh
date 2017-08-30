#!/bin/bash

cat << EOF > /etc/systemd/system/docker.service.d/10-docker-override.conf
[Service]
ExecStart=/usr/bin/dockerd $DOCKER_SELINUX $DOCKER_OPTS $DOCKER_CGROUPS $DOCKER_OPT_BIP $DOCKER_OPT_MTU $DOCKER_OPT_IPMASQ
EOF
systemctl restart docker
systemctl enable docker