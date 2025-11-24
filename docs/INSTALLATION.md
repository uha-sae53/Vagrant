# Guide d'Installation

Ce document décrit les étapes nécessaires pour installer et configurer l'environnement Vagrant.

## Prérequis

Avant de commencer, assurez-vous d'avoir les éléments suivants installés sur votre système :

### Logiciels Requis

1. **VirtualBox** (version 6.1 ou supérieure)
   - Téléchargement : https://www.virtualbox.org/wiki/Downloads
   - Installation recommandée avec les Extension Pack

2. **Vagrant** (version 2.2 ou supérieure)
   - Téléchargement : https://www.vagrantup.com/downloads
   - Vérifiez l'installation avec : `vagrant --version`

### Configuration Système Minimale

- **RAM** : 10 GB minimum (pour exécuter les 3 VMs simultanément)
- **Espace disque** : 30 GB d'espace libre
- **Processeur** : CPU avec support de virtualisation (Intel VT-x/AMD-V)
- **Système d'exploitation** : Windows 10/11, macOS, ou Linux

## Installation

### 1. Installation de VirtualBox

#### Windows
1. Téléchargez l'installateur depuis le site officiel
2. Exécutez l'installateur avec les privilèges administrateur
3. Suivez les instructions de l'assistant d'installation
4. Redémarrez votre ordinateur si nécessaire

#### macOS
```bash
brew install --cask virtualbox
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install virtualbox
```

### 2. Installation de Vagrant

#### Windows
1. Téléchargez l'installateur depuis vagrantup.com
2. Exécutez l'installateur
3. Redémarrez votre terminal après l'installation

#### macOS
```bash
brew install vagrant
```

#### Linux (Ubuntu/Debian)
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install vagrant
```

## Vérification de l'Installation

Après l'installation, vérifiez que tout fonctionne correctement :

```bash
# Vérifier la version de Vagrant
vagrant --version

# Vérifier la version de VirtualBox
vboxmanage --version
```

## Configuration Post-Installation

### Activer la Virtualisation

Assurez-vous que la virtualisation est activée dans le BIOS de votre ordinateur :

1. Redémarrez votre ordinateur
2. Entrez dans le BIOS (généralement F2, F10, ou DEL au démarrage)
3. Recherchez les options de virtualisation (Intel VT-x ou AMD-V)
4. Activez ces options
5. Sauvegardez et redémarrez

### Plugins Vagrant Recommandés

Installez les plugins suivants pour améliorer votre expérience :

```bash
# Plugin pour gérer automatiquement les VirtualBox Guest Additions
vagrant plugin install vagrant-vbguest

# Plugin pour mettre en cache les boxes
vagrant plugin install vagrant-cachier
```

## Dépannage

### Problèmes Courants

#### Erreur : "VT-x is disabled"
- Solution : Activez la virtualisation dans le BIOS

#### Erreur : "Vagrant cannot forward the specified ports"
- Solution : Vérifiez qu'aucun autre processus n'utilise les ports requis

#### Performance lente
- Solution : Augmentez la RAM allouée aux VMs dans le Vagrantfile
- Solution : Fermez les applications inutiles sur votre machine hôte

## Prochaines Étapes

Une fois l'installation terminée, consultez le [Guide d'Utilisation](USAGE.md) pour apprendre à utiliser l'infrastructure Vagrant.
