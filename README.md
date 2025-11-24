# Infrastructure Vagrant - UHA SAE53

## 📋 Description

Ce dépôt contient une infrastructure Vagrant professionnelle pour déployer un environnement de développement/test complet avec 3 machines virtuelles interconnectées, simulant une architecture applicative à trois niveaux (3-tier).

## 🏗️ Architecture

L'infrastructure se compose de trois serveurs :

- **Web Server** (192.168.56.10) - Serveur web Nginx avec 2 GB RAM
- **App Server** (192.168.56.11) - Serveur applicatif Python avec 3 GB RAM  
- **DB Server** (192.168.56.12) - Serveur de base de données MySQL avec 4 GB RAM

## 🚀 Démarrage Rapide

### Prérequis

- [VirtualBox](https://www.virtualbox.org/) 6.1+
- [Vagrant](https://www.vagrantup.com/) 2.2+
- 10 GB de RAM disponible
- 30 GB d'espace disque

### Installation

```bash
# Cloner le dépôt
git clone https://github.com/uha-sae53/Vagrant.git
cd Vagrant

# Démarrer toute l'infrastructure
vagrant up

# Ou démarrer une VM spécifique
vagrant up web
```

### Vérification

```bash
# Vérifier l'état des VMs
vagrant status

# Se connecter à une VM
vagrant ssh web
```

## 📚 Documentation

La documentation complète est disponible dans le dossier `docs/` :

- [**Guide d'Installation**](docs/INSTALLATION.md) - Instructions détaillées d'installation
- [**Guide d'Utilisation**](docs/USAGE.md) - Commandes et scénarios d'utilisation
- [**Architecture**](docs/ARCHITECTURE.md) - Description de l'architecture et des composants
- [**Dépannage**](docs/TROUBLESHOOTING.md) - Solutions aux problèmes courants

## 🔧 Configuration

Les VMs peuvent être personnalisées en modifiant le fichier `Vagrantfile`. Par exemple, pour augmenter la RAM :

```ruby
vb.memory = "4096"  # Augmenter à 4 GB
vb.cpus = 4         # Augmenter à 4 CPUs
```

## 📊 Ressources Système

| VM | RAM | CPU | IP |
|----|-----|-----|----|
| Web | 2 GB | 2 | 192.168.56.10 |
| App | 3 GB | 2 | 192.168.56.11 |
| DB | 4 GB | 2 | 192.168.56.12 |

**Total requis :** 9 GB RAM minimum (10 GB recommandé)

## 🛠️ Commandes Utiles

```bash
vagrant up              # Démarrer toutes les VMs
vagrant halt            # Arrêter toutes les VMs
vagrant reload          # Redémarrer les VMs
vagrant destroy         # Supprimer toutes les VMs
vagrant status          # Voir l'état des VMs
vagrant ssh <name>      # Se connecter à une VM
vagrant provision       # Ré-exécuter le provisioning
```

## 🔒 Sécurité

⚠️ **IMPORTANT :** Cette configuration est destinée au développement/test uniquement. Pour un environnement de production, consultez la section Sécurité dans [ARCHITECTURE.md](docs/ARCHITECTURE.md).

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.

## 📝 Licence

Ce projet est fourni à des fins éducatives dans le cadre du cours SAE53 à l'UHA.

## 👥 Auteurs

- UHA SAE53

## 📞 Support

Pour toute question ou problème :
- Consultez la [documentation](docs/)
- Ouvrez une [issue](https://github.com/uha-sae53/Vagrant/issues)
- Référez-vous au [guide de dépannage](docs/TROUBLESHOOTING.md)
