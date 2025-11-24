# Guide de Dépannage

Ce document fournit des solutions aux problèmes courants rencontrés lors de l'utilisation de l'infrastructure Vagrant.

## Table des Matières

1. [Problèmes de Démarrage](#problèmes-de-démarrage)
2. [Problèmes de Réseau](#problèmes-de-réseau)
3. [Problèmes de Performance](#problèmes-de-performance)
4. [Problèmes de Provisioning](#problèmes-de-provisioning)
5. [Problèmes VirtualBox](#problèmes-virtualbox)

## Problèmes de Démarrage

### Erreur : VT-x is not available

**Symptôme :**
```
VBoxManage.exe: error: VT-x is not available (VERR_VMX_NO_VMX)
```

**Causes possibles :**
- La virtualisation n'est pas activée dans le BIOS
- Hyper-V est activé sous Windows (incompatible avec VirtualBox)

**Solutions :**

1. Activer la virtualisation dans le BIOS :
   - Redémarrez et entrez dans le BIOS (F2, F10, ou DEL)
   - Cherchez "Intel VT-x" ou "AMD-V"
   - Activez l'option et sauvegardez

2. Désactiver Hyper-V sous Windows :
```powershell
# Exécuter en tant qu'administrateur
bcdedit /set hypervisorlaunchtype off
# Redémarrer l'ordinateur
```

### Erreur : The box failed to unpackage properly

**Symptôme :**
```
The box failed to unpackage properly. Please verify that the box file you're trying to add is not corrupted
```

**Solution :**
```bash
# Supprimer la box corrompue
vagrant box remove ubuntu/focal64

# Nettoyer le cache
rm -rf ~/.vagrant.d/tmp/*

# Télécharger à nouveau
vagrant box add ubuntu/focal64
```

### Erreur : Vagrant cannot forward the specified ports

**Symptôme :**
```
Vagrant cannot forward the specified ports on this VM
```

**Solution :**
```bash
# Trouver le processus utilisant le port
netstat -ano | findstr :8080  # Windows
lsof -i :8080                 # Linux/macOS

# Modifier le port dans le Vagrantfile ou arrêter le processus conflictuel
```

## Problèmes de Réseau

### Les VMs ne peuvent pas communiquer entre elles

**Diagnostic :**
```bash
# Sur web-server
vagrant ssh web
ping 192.168.56.11  # Devrait atteindre app-server
```

**Solutions :**

1. Vérifier la configuration réseau :
```bash
vagrant ssh web
ip addr show
# Vérifier que l'interface a bien l'IP 192.168.56.10
```

2. Redémarrer le réseau :
```bash
sudo systemctl restart networking
```

3. Recréer les VMs :
```bash
vagrant destroy -f
vagrant up
```

### Pas d'accès Internet depuis les VMs

**Diagnostic :**
```bash
vagrant ssh web
ping 8.8.8.8
```

**Solution :**
```bash
# Vérifier la configuration DNS
cat /etc/resolv.conf

# Redémarrer la VM avec reconfiguration réseau
vagrant reload web
```

## Problèmes de Performance

### Les VMs sont très lentes

**Causes possibles :**
- RAM insuffisante sur la machine hôte
- Trop de VMs démarrées simultanément
- Disque dur saturé

**Solutions :**

1. Vérifier l'utilisation des ressources :
```bash
# Sur l'hôte
vagrant status
htop  # ou Task Manager sous Windows
```

2. Augmenter les ressources allouées dans le Vagrantfile :
```ruby
vb.memory = "4096"  # Augmenter la RAM
vb.cpus = 4         # Augmenter les CPUs
```

3. Démarrer uniquement les VMs nécessaires :
```bash
vagrant halt app db  # Arrêter les VMs non utilisées
vagrant up web       # Garder seulement le serveur web
```

4. Activer le mode PAE/NX :
```ruby
vb.customize ["modifyvm", :id, "--pae", "on"]
```

### Provisioning très lent

**Solution :**
```bash
# Installer le plugin de cache
vagrant plugin install vagrant-cachier

# Ajouter au Vagrantfile
config.cache.scope = :box
```

## Problèmes de Provisioning

### Le provisioning échoue

**Symptôme :**
```
==> web: Running provisioner: shell...
The following packages have unmet dependencies
```

**Solutions :**

1. Mettre à jour les dépôts :
```bash
vagrant ssh web
sudo apt-get update
sudo apt-get upgrade
```

2. Ré-exécuter le provisioning :
```bash
vagrant provision web
```

3. Provisioning en mode debug :
```bash
vagrant up web --debug
```

### Erreur : apt-get install fails

**Solution :**
```bash
# Se connecter à la VM
vagrant ssh web

# Corriger les dépendances cassées
sudo apt-get update
sudo apt-get -f install
sudo dpkg --configure -a
```

## Problèmes VirtualBox

### Erreur : VBoxManage: error

**Symptôme :**
```
There was an error while executing VBoxManage
```

**Solutions :**

1. Vérifier l'installation de VirtualBox :
```bash
vboxmanage --version
```

2. Réinstaller VirtualBox Extension Pack :
   - Télécharger depuis https://www.virtualbox.org/
   - Installer l'Extension Pack correspondant à votre version

3. Réinitialiser VirtualBox :
```bash
# Windows (en tant qu'administrateur)
sc stop vboxdrv
sc start vboxdrv

# Linux
sudo /sbin/vboxconfig
```

### Les Guest Additions ne se mettent pas à jour

**Solution :**
```bash
# Installer le plugin
vagrant plugin install vagrant-vbguest

# Mettre à jour les Guest Additions
vagrant vbguest --do install web
```

### Erreur : NS_ERROR_FAILURE

**Symptôme :**
```
NS_ERROR_FAILURE (0x80004005)
```

**Solutions :**

1. Supprimer les fichiers de verrouillage :
```bash
# Windows
cd %USERPROFILE%\VirtualBox VMs
# Supprimer les fichiers .lock

# Linux/macOS
cd ~/VirtualBox\ VMs
find . -name "*.lock" -delete
```

2. Détruire et recréer la VM :
```bash
vagrant destroy web -f
vagrant up web
```

## Problèmes de SSH

### Timeout lors de la connexion SSH

**Symptôme :**
```
Timed out while waiting for the machine to boot
```

**Solutions :**

1. Augmenter le timeout :
```ruby
# Dans le Vagrantfile
config.vm.boot_timeout = 600
```

2. Vérifier la configuration SSH :
```bash
vagrant ssh-config web
```

3. Essayer une connexion manuelle :
```bash
vagrant ssh web -- -vvv
```

### Permission denied (publickey)

**Solution :**
```bash
# Générer de nouvelles clés
cd ~/.vagrant.d
mv insecure_private_key insecure_private_key.bak
vagrant up web
```

## Problèmes d'Espace Disque

### Manque d'espace sur le disque hôte

**Solutions :**

1. Nettoyer les boxes inutilisées :
```bash
vagrant box list
vagrant box remove <box-name>
vagrant box prune
```

2. Supprimer les VMs orphelines :
```bash
vagrant global-status --prune
```

3. Nettoyer les logs :
```bash
# Supprimer les logs VirtualBox
rm -rf ~/VirtualBox\ VMs/*/Logs/*
```

### Manque d'espace sur la VM

**Solution :**
```bash
# Augmenter la taille du disque
VBoxManage modifyhd <disk.vdi> --resize 20480  # 20 GB

# Se connecter et redimensionner la partition
vagrant ssh web
sudo resize2fs /dev/sda1
```

## Commandes de Diagnostic Utiles

```bash
# Vérifier la version de tous les composants
vagrant --version
vboxmanage --version

# Voir les logs complets
vagrant up web --debug > vagrant.log 2>&1

# Vérifier l'état de toutes les VMs
vagrant global-status --prune

# Vérifier les plugins installés
vagrant plugin list

# Tester la connectivité réseau
vagrant ssh web -c "ip addr show"
vagrant ssh web -c "ping -c 3 192.168.56.11"

# Vérifier les ressources système
vagrant ssh web -c "free -h"
vagrant ssh web -c "df -h"
```

## Réinitialisation Complète

Si tous les autres diagnostics échouent, une réinitialisation complète peut être nécessaire :

```bash
# 1. Détruire toutes les VMs
vagrant destroy -f

# 2. Supprimer toutes les boxes
vagrant box list | cut -d ' ' -f 1 | xargs -n 1 vagrant box remove -f

# 3. Nettoyer le cache Vagrant
rm -rf ~/.vagrant.d/tmp/*
rm -rf ~/.vagrant.d/boxes/*

# 4. Redémarrer VirtualBox
# Windows : Redémarrer les services VirtualBox
# Linux/macOS : sudo /sbin/vboxconfig

# 5. Recréer l'infrastructure
vagrant up
```

## Obtenir de l'Aide

Si aucune de ces solutions ne fonctionne :

1. Consultez la documentation officielle :
   - Vagrant : https://www.vagrantup.com/docs
   - VirtualBox : https://www.virtualbox.org/manual/

2. Recherchez sur les forums :
   - Vagrant Discussions : https://discuss.hashicorp.com/c/vagrant
   - Stack Overflow : tag `vagrant`

3. Créez un rapport de bug avec les informations suivantes :
   - Version de Vagrant et VirtualBox
   - Système d'exploitation
   - Fichier Vagrantfile
   - Logs complets (`vagrant up --debug`)
