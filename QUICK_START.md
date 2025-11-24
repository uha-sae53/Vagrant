# Guide de Démarrage Rapide

## Installation en 3 étapes

### 1. Installer les prérequis

Téléchargez et installez :
- Vagrant : https://www.vagrantup.com/downloads
- VirtualBox : https://www.virtualbox.org/wiki/Downloads

### 2. Cloner le repository

```bash
git clone https://github.com/uha-sae53/Vagrant.git
cd Vagrant
```

### 3. Démarrer l'infrastructure

```bash
vagrant up
```

Attendez quelques minutes le temps que les VMs se créent et se configurent.

## Vérification

Une fois le démarrage terminé, vérifiez que tout fonctionne :

```bash
# Vérifier l'état des VMs
vagrant status

# Tester le serveur web
curl http://localhost:8080

# Se connecter à une VM
vagrant ssh web
```

## Commandes Essentielles

| Commande | Description |
|----------|-------------|
| `vagrant up` | Démarre toutes les VMs |
| `vagrant halt` | Arrête toutes les VMs |
| `vagrant status` | Affiche l'état des VMs |
| `vagrant ssh <nom>` | Se connecte à une VM |
| `vagrant destroy` | Détruit toutes les VMs |

## Noms des VMs

- `web` : Serveur Web (Apache)
- `db` : Serveur Base de données (MySQL)
- `app` : Serveur Application (Node.js)

## Besoin d'aide ?

Consultez le fichier [README.md](README.md) pour la documentation complète.
