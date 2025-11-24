# Infrastructure Vagrant - 3 VMs

Ce repository contient une configuration Vagrant professionnelle pour déployer une infrastructure complète avec 3 machines virtuelles.

## 📋 Description

Ce projet déploie automatiquement 3 machines virtuelles configurées pour simuler une infrastructure d'application web complète :

- **VM 1 - Serveur Web** : Serveur Apache pour héberger le frontend
- **VM 2 - Serveur Base de données** : Serveur MySQL pour la persistance des données
- **VM 3 - Serveur Application** : Serveur Node.js pour le backend

## 🔧 Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- [Vagrant](https://www.vagrantup.com/downloads) (version 2.2.0 ou supérieure)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (version 6.0 ou supérieure)
- Au moins 4 GB de RAM disponible
- Au moins 10 GB d'espace disque disponible

## 🚀 Installation et Utilisation

### Démarrer toutes les VMs

```bash
vagrant up
```

Cette commande va :
1. Télécharger l'image Ubuntu 20.04 LTS si nécessaire
2. Créer et configurer les 3 machines virtuelles
3. Provisionner chaque VM avec les logiciels nécessaires

### Démarrer une VM spécifique

```bash
vagrant up web    # Démarre uniquement le serveur web
vagrant up db     # Démarre uniquement le serveur de base de données
vagrant up app    # Démarre uniquement le serveur d'application
```

### Se connecter à une VM

```bash
vagrant ssh web   # Se connecter au serveur web
vagrant ssh db    # Se connecter au serveur de base de données
vagrant ssh app   # Se connecter au serveur d'application
```

### Arrêter les VMs

```bash
vagrant halt      # Arrête toutes les VMs
vagrant halt web  # Arrête uniquement le serveur web
```

### Redémarrer les VMs

```bash
vagrant reload    # Redémarre toutes les VMs
```

### Détruire les VMs

```bash
vagrant destroy   # Détruit toutes les VMs
vagrant destroy web # Détruit uniquement le serveur web
```

### Vérifier l'état des VMs

```bash
vagrant status    # Affiche l'état de toutes les VMs
```

## 🌐 Configuration Réseau

### Adresses IP privées

- **Serveur Web** : 192.168.56.10
- **Serveur Base de données** : 192.168.56.11
- **Serveur Application** : 192.168.56.12

### Ports redirigés

- **Port 8080** (host) → **Port 80** (web) : Accès au serveur Apache
- **Port 3306** (host) → **Port 3306** (db) : Accès au serveur MySQL
- **Port 8000** (host) → **Port 8000** (app) : Accès au serveur Node.js

### Accéder aux services

- Serveur Web : http://localhost:8080
- MySQL : localhost:3306
- Application : http://localhost:8000

## 💻 Spécifications des VMs

### VM 1 - Serveur Web
- **OS** : Ubuntu 20.04 LTS
- **RAM** : 1 GB
- **CPU** : 1 core
- **Logiciels** : Apache2
- **IP** : 192.168.56.10

### VM 2 - Serveur Base de données
- **OS** : Ubuntu 20.04 LTS
- **RAM** : 2 GB
- **CPU** : 2 cores
- **Logiciels** : MySQL Server
- **IP** : 192.168.56.11

### VM 3 - Serveur Application
- **OS** : Ubuntu 20.04 LTS
- **RAM** : 1 GB
- **CPU** : 1 core
- **Logiciels** : Node.js 18.x, npm
- **IP** : 192.168.56.12

## 🔍 Provisioning

Chaque VM est provisionnée automatiquement lors du premier démarrage :

- **Serveur Web** : Installation et configuration d'Apache2, création d'une page d'accueil
- **Serveur DB** : Installation de MySQL Server
- **Serveur App** : Installation de Node.js et npm

Pour re-provisionner une VM :

```bash
vagrant provision web
```

## 📝 Personnalisation

Pour personnaliser la configuration, modifiez le fichier `Vagrantfile` :

- Changer la quantité de RAM : modifier `vb.memory`
- Changer le nombre de CPUs : modifier `vb.cpus`
- Ajouter des ports : ajouter une ligne `config.vm.network "forwarded_port"`
- Modifier le provisioning : éditer les blocs `config.vm.provision`

## 🐛 Dépannage

### Les VMs ne démarrent pas
- Vérifiez que la virtualisation est activée dans le BIOS
- Vérifiez que VirtualBox est correctement installé
- Essayez `vagrant destroy` puis `vagrant up`

### Problèmes de réseau
- Vérifiez que les IPs ne sont pas déjà utilisées sur votre réseau
- Vérifiez que le réseau host-only de VirtualBox est configuré

### Erreurs de provisioning
- Relancez le provisioning : `vagrant provision`
- Détruisez et recréez la VM : `vagrant destroy <nom> && vagrant up <nom>`

## 📚 Ressources

- [Documentation Vagrant](https://www.vagrantup.com/docs)
- [Documentation VirtualBox](https://www.virtualbox.org/manual/)
- [Vagrant Cloud](https://app.vagrantup.com/boxes/search)

## 📄 Licence

Ce projet est fourni tel quel pour des besoins éducatifs et professionnels.

## ✨ Auteur

Projet créé pour l'infrastructure SAE53
