# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "geerlingguy/centos7"
  #config.ssh.insert_key = false
  #config.vm.box_check_update = false
  #config.ssh.forward_agent = true
  config.vm.boot_timeout    = 900
  config.vm.network "private_network", ip: "192.168.66.10"
  config.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--cpuexecutioncap", "20"]
      vb.gui = false
      vb.memory = "382"
  end
  #Wrapper
  config.vm.synced_folder "../WrapperGrayLogZendLogger", "/www/wrappergraylogzendlogger.com", disabled: (not FileTest::directory?("../WrapperGrayLogZendLogger"))
  #Magento1
  config.vm.synced_folder "../magentoTraining", "/www/magentotraining.local.com", disabled: (not FileTest::directory?("../magentoTraining"))
  #Magento2
  config.vm.synced_folder "../magento2Training", "/www/magento2training.local.com", disabled: (not FileTest::directory?("../magento2Training"))
  #Aprovisionamiento
  config.vm.provision :shell do |shell|
        shell.path      = "vagrant/bootstrap.sh"
  end
end