Vagrant.configure("2") do |config|

  config.vm.box = "bento/centos-stream-9"

  config.vm.hostname = "centos"

  config.vm.provider "vmware_desktop" do |vm|
    vm.memory = 2048
    vm.cpus = 2
  end

  config.vm.network "private_network", ip: "192.168.56.10"

end
