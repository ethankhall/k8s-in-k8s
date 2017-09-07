# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  
  config.vm.box = "centos/7"

  (0..1).each do |i|
    config.vm.define vm_name = "centos%d" % i do |box|
      box.vm.provider "vmware_fusion" do |v|
        v.vmx["memsize"] = "1024"
        v.vmx["numvcpus"] = "1"
      end

      box.vm.network :private_network, ip: "172.17.4.#{i+100}"

      box.vm.provision "shell" do |s|
        s.path = "scripts/networking.sh"
        s.privileged = true
        s.env = { 'IP_ADDR' => "172.17.4.#{i+100}" }
      end

      box.vm.provision "shell" do |s|
        s.path = "scripts/basic-config.sh"
        s.privileged = true
        s.env = { 'REPO' => "quay.io/ethankhall" }
      end

      if i == 0
        box.vm.provision "shell" do |s|
          s.path = "scripts/etcd.sh"
          s.privileged = true
          s.env = { 'REPO' => "quay.io/ethankhall", 'POD_NETWORK' => "10.2.0.0/16" }
        end
      end

      box.vm.provision "shell" do |s|
        s.path = "scripts/flannel.sh"
        s.privileged = true
        s.env = { 
          'ETCD_ENDPOINTS' => "http://172.17.4.100:2379",
          'IP_ADDR' => "172.17.4.#{i+100}"
        }
      end

      box.vm.provision "shell" do |s|
        s.path = "scripts/docker.sh"
        s.privileged = true
      end

      if i == 0 || i == 1
        box.vm.provision "shell" do |s|
          s.path = "scripts/cluster-cert.sh"
          s.privileged = true
          s.env = { 'CLUSTER_IP' => "172.17.4.100" }
        end

        if i == 0
          box.vm.provision "shell" do |s|
            s.path = "scripts/control-plane-cluster.sh"
            s.privileged = true
            s.env = { 
              'ETCD_ENDPOINTS' => "http://172.17.4.100:2379", 
              'IP_ADDR' => "172.17.4.#{i+100}", 
              'REPO' => "quay.io/ethankhall" 
            }
          end
        end

        if i == 1
          box.vm.provision "shell" do |s|
            s.path = "scripts/kubelet.sh"
            s.privileged = true
            s.env = { 
              'ETCD_ENDPOINTS' => "http://172.17.4.100:2379", 
              'MASTER_URL' => 'https://172.17.4.100:6443', 
              'HOST_NAME' => "172.17.4.#{i+100}", 
              'REPO' => "quay.io/ethankhall",
              'POD_NETWORK' => "10.2.0.0/16"
            }
          end
        end
      end

    end
  end
end
