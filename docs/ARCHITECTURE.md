# Architecture de l'Infrastructure

## Vue d'Ensemble

Cette infrastructure Vagrant déploie un environnement de développement/test complet composé de trois serveurs interconnectés, simulant une architecture applicative typique à trois niveaux (3-tier architecture).

## Diagramme d'Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Machine Hôte                              │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           Réseau Privé (192.168.56.0/24)            │    │
│  │                                                       │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │    │
│  │  │  Web Server  │  │  App Server  │  │ DB Server │ │    │
│  │  │              │  │              │  │           │ │    │
│  │  │  Nginx       │→ │  Python      │→ │  MySQL    │ │    │
│  │  │              │  │              │  │           │ │    │
│  │  │ .56.10:80    │  │ .56.11       │  │ .56.12    │ │    │
│  │  │ RAM: 2GB     │  │ RAM: 3GB     │  │ RAM: 4GB  │ │    │
│  │  │ CPU: 2       │  │ CPU: 2       │  │ CPU: 2    │ │    │
│  │  └──────────────┘  └──────────────┘  └───────────┘ │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Composants de l'Infrastructure

### 1. Serveur Web (web-server)

**Fonction :** Point d'entrée de l'infrastructure, serveur de contenu statique et reverse proxy

**Spécifications :**
- **Nom d'hôte :** web-server
- **Adresse IP :** 192.168.56.10
- **RAM :** 2048 MB (2 GB)
- **CPU :** 2 cœurs
- **Box :** ubuntu/focal64
- **Logiciels :** Nginx

**Rôle :**
- Servir les fichiers statiques (HTML, CSS, JavaScript)
- Agir comme reverse proxy vers le serveur applicatif
- Gérer les certificats SSL/TLS (en production)
- Load balancing (avec configuration avancée)

**Ports exposés :**
- 80 : HTTP
- 443 : HTTPS (configurable)

### 2. Serveur Applicatif (app-server)

**Fonction :** Exécution de la logique métier et traitement des requêtes

**Spécifications :**
- **Nom d'hôte :** app-server
- **Adresse IP :** 192.168.56.11
- **RAM :** 3072 MB (3 GB)
- **CPU :** 2 cœurs
- **Box :** ubuntu/focal64
- **Logiciels :** Python 3, pip

**Rôle :**
- Exécuter l'application backend
- Traiter les requêtes API
- Gérer la logique métier
- Communiquer avec la base de données

**Frameworks supportés :**
- Flask
- Django
- FastAPI
- Autres frameworks Python

### 3. Serveur de Base de Données (db-server)

**Fonction :** Stockage et gestion des données

**Spécifications :**
- **Nom d'hôte :** db-server
- **Adresse IP :** 192.168.56.12
- **RAM :** 4096 MB (4 GB)
- **CPU :** 2 cœurs
- **Box :** ubuntu/focal64
- **Logiciels :** MySQL Server 8.0

**Rôle :**
- Stocker les données applicatives
- Gérer les transactions
- Assurer la persistance des données
- Fournir des fonctionnalités de backup/restore

**Ports exposés :**
- 3306 : MySQL (accessible depuis le réseau privé)

## Réseau

### Configuration Réseau

L'infrastructure utilise un réseau privé VirtualBox pour permettre la communication entre les serveurs :

- **Type :** Private Network (Host-Only)
- **Plage IP :** 192.168.56.0/24
- **Passerelle :** Gérée par VirtualBox
- **DNS :** Configuré automatiquement

### Communication Inter-Serveurs

```
┌──────────┐     HTTP/API      ┌──────────┐    SQL/3306    ┌──────────┐
│   Web    │ ───────────────→  │   App    │ ─────────────→ │    DB    │
│  .56.10  │                   │  .56.11  │                │  .56.12  │
└──────────┘                   └──────────┘                └──────────┘
```

### Règles de Firewall (Recommandées)

```bash
# Web Server
- Autorise: Port 80, 443 depuis l'extérieur
- Autorise: Tout le trafic vers 192.168.56.11

# App Server  
- Autorise: Connexions depuis 192.168.56.10
- Autorise: Connexions vers 192.168.56.12:3306
- Bloque: Accès direct depuis l'extérieur

# DB Server
- Autorise: Connexions depuis 192.168.56.11 sur port 3306
- Bloque: Tout autre trafic entrant
```

## Provisioning

### Stratégie de Provisioning

Le provisioning est effectué via des scripts shell inline lors de la première exécution de `vagrant up`. Cette approche permet :

- Installation rapide des composants de base
- Configuration minimale pour démarrer
- Flexibilité pour personnalisation ultérieure

### Séquence de Provisioning

1. **Mise à jour du système** : `apt-get update`
2. **Installation des paquets** : Installation des logiciels spécifiques à chaque serveur
3. **Configuration des services** : Activation et démarrage des services
4. **Scripts personnalisés** : Exécution de scripts additionnels si présents

### Provisioning Avancé (Optionnel)

Pour des configurations plus complexes, vous pouvez utiliser :

- **Ansible** : Gestion de configuration déclarative
- **Puppet** : Automatisation de l'infrastructure
- **Chef** : Configuration management
- **Scripts Shell externes** : Scripts bash modulaires

## Stockage

### Dossiers Synchronisés

Par défaut, Vagrant synchronise le dossier du projet :

```
Hôte: <chemin_du_projet>/Vagrant (ex: /home/user/projects/Vagrant)
VM: /vagrant
```

### Recommandations de Stockage

- **Logs** : `/var/log/` sur chaque VM
- **Données applicatives** : `/opt/app/` ou `/var/www/`
- **Bases de données** : `/var/lib/mysql/`
- **Backups** : Dossier synchronisé pour sauvegarde vers l'hôte

## Sécurité

### Considérations de Sécurité

**⚠️ IMPORTANT :** Cette configuration est destinée au développement/test uniquement.

Pour un environnement de production, les mesures suivantes sont INDISPENSABLES :

1. **Pare-feu**
   - Configurer UFW ou iptables
   - Restreindre l'accès aux ports nécessaires uniquement

2. **SSH**
   - Désactiver l'authentification par mot de passe
   - Utiliser uniquement des clés SSH
   - Changer le port SSH par défaut

3. **Base de Données**
   - Créer des utilisateurs avec privilèges minimaux
   - Utiliser des mots de passe forts
   - Limiter les connexions réseau

4. **Mises à jour**
   - Activer les mises à jour automatiques de sécurité
   - Surveiller les CVE des logiciels installés

5. **Monitoring**
   - Installer des outils de monitoring (Prometheus, Grafana)
   - Configurer des alertes

## Scalabilité

### Options de Mise à l'Échelle

Cette architecture peut être étendue de plusieurs façons :

1. **Horizontal Scaling**
   ```ruby
   # Ajouter plusieurs serveurs web
   (1..3).each do |i|
     config.vm.define "web#{i}" do |web|
       # Configuration...
     end
   end
   ```

2. **Load Balancing**
   - Ajouter un serveur HAProxy ou Nginx en front
   - Distribuer la charge entre plusieurs app servers

3. **Réplication de Base de Données**
   - Configuration Master-Slave MySQL
   - Réplication pour haute disponibilité

4. **Cache**
   - Ajouter Redis ou Memcached
   - Améliorer les performances

## Backup et Restauration

### Stratégie de Backup

1. **Snapshots Vagrant**
   ```bash
   vagrant snapshot save <vm-name> <snapshot-name>
   ```

2. **Backup de Base de Données**
   ```bash
   vagrant ssh db -c "mysqldump -u root database > /vagrant/backup.sql"
   ```

3. **Export VirtualBox**
   ```bash
   VBoxManage export UHA-DB-Server -o db-backup.ova
   ```

## Performance

### Optimisations Possibles

1. **Augmentation des ressources**
   - Modifier RAM et CPU dans le Vagrantfile
   - Adapter selon les besoins réels

2. **SSD**
   - Stocker les VMs sur un SSD
   - Améliore considérablement les I/O

3. **Paravirtualisation**
   ```ruby
   vb.customize ["modifyvm", :id, "--paravirtprovider", "kvm"]
   ```

4. **Cache de paquets**
   - Utiliser vagrant-cachier
   - Réduire le temps de provisioning

## Monitoring et Logs

### Accès aux Logs

```bash
# Logs Nginx (Web Server)
vagrant ssh web -c "sudo tail -f /var/log/nginx/access.log"

# Logs MySQL (DB Server)
vagrant ssh db -c "sudo tail -f /var/log/mysql/error.log"

# Logs système
vagrant ssh app -c "sudo journalctl -f"
```

### Outils de Monitoring Recommandés

- **htop** : Monitoring des ressources système
- **netstat** : Monitoring réseau
- **mysqltuner** : Optimisation MySQL
- **Prometheus + Grafana** : Stack de monitoring complet

## Maintenance

### Tâches de Maintenance Régulières

1. **Mises à jour système**
   ```bash
   vagrant ssh web -c "sudo apt-get update && sudo apt-get upgrade"
   ```

2. **Nettoyage des logs**
   ```bash
   vagrant ssh web -c "sudo logrotate -f /etc/logrotate.conf"
   ```

3. **Vérification de l'espace disque**
   ```bash
   vagrant ssh db -c "df -h"
   ```

4. **Backup réguliers**
   - Automatiser avec des cron jobs
   - Stocker en dehors de l'infrastructure

## Évolution Future

### Améliorations Possibles

1. **Containerisation**
   - Migration vers Docker/Kubernetes
   - Déploiement plus rapide

2. **CI/CD**
   - Intégration avec Jenkins, GitLab CI
   - Déploiement automatisé

3. **Infrastructure as Code**
   - Terraform pour le provisioning
   - Ansible pour la configuration

4. **Cloud Migration**
   - Adapter pour AWS, Azure, GCP
   - Utiliser vagrant-aws, vagrant-azure plugins
