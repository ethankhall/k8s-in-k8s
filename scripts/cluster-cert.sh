#!/bin/bash


mkdir -p /etc/kubernetes/pki
cp /vagrant/certs/${CLUSTER_IP}/*.pem /etc/kubernetes/pki