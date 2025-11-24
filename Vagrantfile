Vagrant.configure("2") do |config|
    # Utilisation de l'image Debian Bullseye 64-bit
    config.vm.box = "debian/bullseye64"
    config.vm.synced_folder ".", "/vagrant", type: "rsync"

    
    # Configuration du provider libvirt (virtualisation)
    config.vm.provider "libvirt" do |libvirt|
        libvirt.memory = 1024 
        libvirt.cpus = 1
    end

    # Définition de la VM master
    config.vm.define "vm-master" do |vm|
        vm.vm.network "private_network", ip: "192.168.56.10"
        vm.vm.hostname = "master"
    end
    
    # Création de 2 VMs slave (slave-1 et slave-2)
    (1..2).each do |i|
        config.vm.define "vm-slave-#{i}" do |vm|
            vm.vm.network "private_network", ip: "192.168.56.1#{i}"
            vm.vm.hostname = "slave-#{i}"
        end
    end
end
