#!/bin/bash

/usr/bin/kube-scheduler \
  --leader-elect=true \
  --master=${MASTER_URL} \
  --v=2