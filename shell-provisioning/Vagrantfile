Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"
  config.ssh.insert_key = true

  config.vm.provider "libvirt" do |libvirt|
    libvirt.memory = 2048
    libvirt.cpus = 2
    libvirt.cpu_mode = "host-passthrough"
  end

  config.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 4, nfs_udp: false

  config.vm.provision "shell", path: "provision.sh"

  config.vm.define "vm-master", primary: true do |vm|
    vm.vm.network "private_network", ip: "192.168.56.10"
    vm.vm.hostname = "master"
  end

  (1..2).each do |i|
    config.vm.define "vm-slave-#{i}" do |vm|
      vm.vm.network "private_network", ip: "192.168.56.1#{i}"
      vm.vm.hostname = "slave-#{i}"
    end
  end
end
