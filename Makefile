export REGISTRY=localhost

.PHONY: clean

define remove_postfix
$(shell echo $(1) | sed 's/\..*//g')
endef

define make_tag_name
quay.io/ethankhall/$(call remove_postfix,$(1)):latest
endef

define find_dockerfile
docker-files/$(call remove_postfix,$(1)).Dockerfile
endef

certs/kubeconfig:
	./generate-certs.sh $(MY_IP)

%.docker: certs/kubeconfig
	docker build -t $(call make_tag_name,$@) --file $(call find_dockerfile,$@) .

%.push: certs/kubeconfig
	docker push $(call make_tag_name,$@)

all: clean kube-api-server.docker etcd.docker kube-controller-manager.docker kube-master.docker kube-proxy.docker kube-scheduler.docker

push: all kube-api-server.push etcd.push kube-controller-manager.push kube-master.push kube-proxy.push kube-scheduler.push

clean:
	rm -rf certs

build: all

kube-scheduler.local: kube-scheduler.docker
	docker run -it --rm -p 10251:10251 --env MASTER_IP=$(MY_IP) $(call make_tag_name,$@)

kube-api-server.local: api-server.docker
	docker run -it --rm -p 6443:6443 --env ETCD_SERVERS=http://$(MY_IP):2379 --env IP_ADDR=$(MY_IP) $(call make_tag_name,$@)

etcd.local: etcd.docker
	docker run -it --rm -p 2380:2380 -p 2379:2379 --env MY_IP=$(MY_IP) --env INITAL_CLUSTER=etcd0=http://$(MY_IP):2380 $(call make_tag_name,$@)

kube-controller-manager.local: kube-controller-manager.docker
	docker run -it --rm --env MASTER_IP=$(MY_IP) $(call make_tag_name,$@)

kube-master.local: kube-master.docker
	docker run -it --rm --env -p 10251:10251 ETCD_SERVERS=http://$(MY_IP):2379 --env IP_ADDR=$(MY_IP) $(call make_tag_name,$@)

kube-proxy.local: kube-proxy.docker
	docker run -it --rm --env MASTER_IP=$(MY_IP) $(call make_tag_name,$@)