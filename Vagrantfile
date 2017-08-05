# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  
  config.vm.box = "centos/7"

  (0..0).each do |i|
    config.vm.define vm_name = "centos%d" % i do |box|
      box.vm.provider "vmware_fusion" do |v|
        v.vmx["memsize"] = "512"
        v.vmx["numvcpus"] = "1"
      end

      box.vm.network :private_network, ip: "172.17.4.#{i+100}"

      box.vm.provision "shell" do |s|
        s.path = "scripts/basic-config.sh"
        s.privileged = true
      end

      if i == 0
        box.vm.provision "shell" do |s|
          s.path = "scripts/etcd.sh"
          s.privileged = true
        end
      end

      box.vm.provision "shell" do |s|
        s.path = "scripts/flannel.sh"
        s.privileged = true
        s.env = { 'ETCD_ENDPOINTS' => "http://172.17.4.100:2379", 'IP_ADDR' => "172.17.4.#{i+100}" }
      end
    
    end
  end
end
