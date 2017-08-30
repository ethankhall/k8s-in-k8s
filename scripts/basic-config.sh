#!/bin/bash

yum-config-manager --add-repo http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
rpm --import https://packages.cloud.google.com/yum/doc/yum-key.gpg
rpm --import https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install --nogpgcheck -y flannel rkt docker-ce lsof vim
systemctl enable docker

cat << EOF > /etc/selinux/config
SELINUX=disabled
SELINUXTYPE=targeted
EOF

rkt trust --prefix "${REPO}" --skip-fingerprint-review

usermod -a -G docker vagrant

setenforce 0 || true