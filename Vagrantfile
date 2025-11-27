Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"

  config.vm.provider "libvirt" do |libvirt|
    libvirt.memory = 2048
    libvirt.cpus = 2
  end

  # Script commun pour toutes les VMs
  config.vm.provision "shell", path: "provision.sh"

  # MASTER - primary: true pour forcer le démarrage en premier lors de "vagrant up"
  config.vm.define "vm-master", primary: true do |vm|
    vm.vm.network "private_network", ip: "192.168.56.10"
    vm.vm.hostname = "master"
  end

  # WORKERS - Démarrent automatiquement après le master grâce à l'ordre de définition
  (1..2).each do |i|
    config.vm.define "vm-slave-#{i}" do |vm|
      vm.vm.network "private_network", ip: "192.168.56.1#{i}"
      vm.vm.hostname = "slave-#{i}"
    end
  end
end
