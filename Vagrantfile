# -*- mode: ruby -*-
# vi: set ft=ruby :

# Configuration professionnelle Vagrant pour 3 VMs
# Ce fichier déploie une infrastructure avec 3 machines virtuelles

Vagrant.configure("2") do |config|
  # Configuration commune pour toutes les VMs
  config.vm.box = "ubuntu/focal64"
  config.vm.box_check_update = true

  # Configuration du provider VirtualBox
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "1024"
    vb.cpus = 1
  end

  # VM 1 - Serveur Web
  config.vm.define "web" do |web|
    web.vm.hostname = "web-server"
    web.vm.network "private_network", ip: "192.168.56.10"
    web.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
    
    web.vm.provider "virtualbox" do |vb|
      vb.name = "vagrant-web-server"
      vb.memory = "1024"
      vb.cpus = 1
    end
    
    # Provisioning basique pour installer Apache
    web.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y apache2
      systemctl enable apache2
      systemctl start apache2
      echo "<h1>Serveur Web - VM 1</h1>" > /var/www/html/index.html
    SHELL
  end

  # VM 2 - Serveur Base de données
  config.vm.define "db" do |db|
    db.vm.hostname = "db-server"
    db.vm.network "private_network", ip: "192.168.56.11"
    db.vm.network "forwarded_port", guest: 3306, host: 3306, host_ip: "127.0.0.1"
    
    db.vm.provider "virtualbox" do |vb|
      vb.name = "vagrant-db-server"
      vb.memory = "2048"
      vb.cpus = 2
    end
    
    # Provisioning basique pour installer MySQL
    db.vm.provision "shell", inline: <<-SHELL
      apt-get update
      export DEBIAN_FRONTEND=noninteractive
      
      # Installation de MySQL avec mot de passe root sécurisé
      debconf-set-selections <<< 'mysql-server mysql-server/root_password password vagrant'
      debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vagrant'
      apt-get install -y mysql-server
      
      systemctl enable mysql
      systemctl start mysql
      
      # Sécurisation basique de MySQL
      mysql -u root -pvagrant <<-SQL
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        FLUSH PRIVILEGES;
SQL
    SHELL
  end

  # VM 3 - Serveur Application
  config.vm.define "app" do |app|
    app.vm.hostname = "app-server"
    app.vm.network "private_network", ip: "192.168.56.12"
    app.vm.network "forwarded_port", guest: 8000, host: 8000, host_ip: "127.0.0.1"
    
    app.vm.provider "virtualbox" do |vb|
      vb.name = "vagrant-app-server"
      vb.memory = "1024"
      vb.cpus = 1
    end
    
    # Provisioning basique pour installer Node.js
    app.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y curl gnupg
      
      # Téléchargement et vérification du script NodeSource
      curl -fsSL https://deb.nodesource.com/setup_18.x -o /tmp/nodesource_setup.sh
      
      # Vérification que le script a été téléchargé correctement
      if [ -f /tmp/nodesource_setup.sh ]; then
        bash /tmp/nodesource_setup.sh
        apt-get install -y nodejs
        rm /tmp/nodesource_setup.sh
      else
        echo "Erreur: Impossible de télécharger le script NodeSource"
        exit 1
      fi
      
      node --version
      npm --version
    SHELL
  end
end
