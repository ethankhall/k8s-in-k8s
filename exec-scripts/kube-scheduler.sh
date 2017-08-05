#!/bin/bash

/usr/bin/kube-scheduler \
  --leader-elect=true \
  --master=http://${MASTER_IP}:6443 \
  --v=2