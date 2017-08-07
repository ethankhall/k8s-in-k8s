# k8s in k8s

This repo is intended to have an example of kubernetes (k8s) running on two hosts, then having that "control plane" cluster manage k8s infrastrucutre for other k8s clusters.
The hope is that you could have a k8s run by a central team, and provide k8s clusters as a service.

## Running Locally

This project uses Make to manage the execution, publishing, etc of docker containers. To do this you *must* execute things with a paramerter passed to make. You can do this like:

    make MY_IP=172.17.4.100 <target>

The targets are defined in a few ways. There are a few apps that this project maintains:
- kube-api-server
- etcd
- kube-controller-manager
- kube-control-plane-master
- kube-proxy
- kube-scheduler

For each of these apps you can run a build, deploy, and push. To do that you would do `<name>.docker` to build, `<name>.local` to run it locally, and `<name>.push` to push to a registry.

## In a cluster.
This project uses [vagrant](vagrantup.com) to start and manage the vm's.

There are 4 machines:
- centos0 - api server for control plane cluster
- centos1 - worker for the control plane cluster
- centos2 - worker for test cluster
- centos3 - worker for test cluster

### Quick Intro

`vagrant up` starts the cluster
`vagrant status` shows you the status of the cluster (machine is up or not)
`vagrant ssh centos<#>` ssh's you into the cluster machine. Use the names from `vagrant status` to see possible options.

# Pre Build kubectl
You can use a 'pre-build' kubectl that will configure it'self for your env. You can use this by running `./certs/<IP>/kubectl-local.sh` where the `<IP>` is what was used in the make arugment. This will be 
`172.17.4.100` for the control plane master.