#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KUBECONFIG="${KUBECONFIG}:${DIR}/certs/kubeconfig" kubectl --context bootcfg-context "$@"