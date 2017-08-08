#!/bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
fi

export MASTER_IP=$1
echo "The local IP is: ${MASTER_IP}"
mkdir -p $DIR/certs/${MASTER_IP}
cd $DIR/certs/${MASTER_IP}

CERT_DIR=$(pwd)

cat <<EOF > ca-config.json
{
    "signing": {
        "default": {
            "expiry": "43800h"
        },
        "profiles": {
            "server": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            },
            "peer": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            },
            "service": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}
EOF

echo '{"CN":"k8s.com","key":{"algo":"rsa","size":2048}}' | cfssl gencert -initca - | cfssljson -bare ca -

echo '{
  "CN": "kube-apiserver.k8s.com",
  "O": "Sever Lobster",
  "hosts": [
    "127.0.0.1",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster.local",
    "*.k8s.com"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "CA",
      "O": "Me",
      "ST": "RoughElectrical",
      "OU": "Rough Electrical"
    }
  ]
}' | jq ".hosts |= . + [ \"${MASTER_IP}\" ]" | \
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem  -config=ca-config.json -profile=server - | \
    cfssljson -bare apiserver

echo '{
  "CN": "kubelet.k8s.com",
  "O": "Rough Electrical",
  "hosts": [
    "127.0.0.1",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster.local",
    "*.k8s.com"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "CA",
      "O": "RoughElectrical",
      "ST": "San Francisco",
      "OU": "Rough Electrical"
    }
  ]
}' |  jq ".hosts |= . + [ \"${MASTER_IP}\" ]" | \
    cfssl gencert -ca=ca.pem  -ca-key=ca-key.pem  -config=ca-config.json -profile=client - | \
    cfssljson -bare worker

echo '{
  "CN": "admin.k8s.com",
  "O": "RoughElectrical",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "CA",
      "O": "RoughElectrical",
      "ST": "San Francisco",
      "OU": "Rough Electrical"
    }
  ]
}' | cfssl gencert -ca=ca.pem  -ca-key=ca-key.pem  -config=ca-config.json -profile=client - | cfssljson -bare admin

echo '{
  "CN": "service.k8s.com",
  "O": "RoughElectrical",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "CA",
      "O": "RoughElectrical",
      "ST": "San Francisco",
      "OU": "Rough Electrical"
    }
  ]
}' | cfssl gencert -ca=ca.pem  -ca-key=ca-key.pem  -config=ca-config.json -profile=service - | cfssljson -bare service

cat << EOF > kubeconfig
apiVersion: v1
kind: Config
users:
- name: bootcfg-user
  user:
    client-certificate: ${CERT_DIR}/admin.pem
    client-key: ${CERT_DIR}/admin-key.pem
clusters:
- name: bootcfg-cluster
  cluster:
    certificate-authority: ${CERT_DIR}/ca.pem
    server: https://${MASTER_IP}:6443
contexts:
- context:
    cluster: bootcfg-cluster
    user: bootcfg-user
  name: bootcfg-context
current-context: bootcfg-context
EOF

cat << EOF > kubectl-local.sh
#!/bin/bash

KUBECONFIG="${KUBECONFIG}:${CERT_DIR}/kubeconfig" kubectl --context bootcfg-context "\$@"
EOF

chmod +x kubectl-local.sh