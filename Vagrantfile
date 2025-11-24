# -*- mode: ruby -*-
# vi: set ft=ruby :

# Configuration Vagrant pour déployer 3 machines virtuelles
# Version: 1.0

Vagrant.configure("2") do |config|
  # Configuration de base commune à toutes les VMs
  config.vm.box = "ubuntu/focal64"
  
  # Configuration du premier serveur - Web Server
  config.vm.define "web" do |web|
    web.vm.hostname = "web-server"
    web.vm.network "private_network", ip: "192.168.56.10"
    
    web.vm.provider "virtualbox" do |vb|
      vb.name = "UHA-Web-Server"
      vb.memory = "2048"
      vb.cpus = 2
    end
    
    web.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y nginx
      systemctl enable nginx
      systemctl start nginx
    SHELL
  end
  
  # Configuration du deuxième serveur - Application Server
  config.vm.define "app" do |app|
    app.vm.hostname = "app-server"
    app.vm.network "private_network", ip: "192.168.56.11"
    
    app.vm.provider "virtualbox" do |vb|
      vb.name = "UHA-App-Server"
      vb.memory = "3072"
      vb.cpus = 2
    end
    
    app.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y python3 python3-pip
    SHELL
  end
  
  # Configuration du troisième serveur - Database Server
  config.vm.define "db" do |db|
    db.vm.hostname = "db-server"
    db.vm.network "private_network", ip: "192.168.56.12"
    
    db.vm.provider "virtualbox" do |vb|
      vb.name = "UHA-DB-Server"
      vb.memory = "4096"
      vb.cpus = 2
    end
    
    db.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y mysql-server
      systemctl enable mysql
      systemctl start mysql
    SHELL
  end
end
