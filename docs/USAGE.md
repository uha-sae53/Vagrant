# Guide d'Utilisation

Ce document explique comment utiliser l'infrastructure Vagrant pour déployer et gérer les 3 machines virtuelles.

## Vue d'Ensemble de l'Infrastructure

L'infrastructure se compose de 3 serveurs :

| Serveur | Nom d'hôte | Adresse IP | RAM | CPU | Rôle |
|---------|-----------|-----------|-----|-----|------|
| Web | web-server | 192.168.56.10 | 2 GB | 2 | Serveur web (Nginx) |
| App | app-server | 192.168.56.11 | 3 GB | 2 | Serveur applicatif (Python) |
| DB | db-server | 192.168.56.12 | 4 GB | 2 | Base de données (MySQL) |

## Commandes de Base

### Démarrage de l'Infrastructure

Pour démarrer toutes les machines virtuelles :

```bash
vagrant up
```

Pour démarrer une seule machine :

```bash
vagrant up web    # Démarre uniquement le serveur web
vagrant up app    # Démarre uniquement le serveur applicatif
vagrant up db     # Démarre uniquement le serveur de base de données
```

### Arrêt des Machines

Arrêter toutes les machines :

```bash
vagrant halt
```

Arrêter une machine spécifique :

```bash
vagrant halt web
```

### Redémarrage

Redémarrer toutes les machines :

```bash
vagrant reload
```

Redémarrer avec re-provisioning :

```bash
vagrant reload --provision
```

### Connexion SSH

Se connecter à une machine virtuelle :

```bash
vagrant ssh web    # Connexion au serveur web
vagrant ssh app    # Connexion au serveur applicatif
vagrant ssh db     # Connexion au serveur de base de données
```

### Statut des Machines

Vérifier l'état de toutes les machines :

```bash
vagrant status
```

Vérifier l'état global avec toutes les boxes Vagrant :

```bash
vagrant global-status
```

### Destruction et Recréation

Détruire toutes les machines (supprime toutes les données) :

```bash
vagrant destroy
```

Détruire une machine spécifique :

```bash
vagrant destroy web
```

Détruire et recréer immédiatement :

```bash
vagrant destroy -f && vagrant up
```

## Gestion des Machines

### Suspension et Reprise

Mettre en pause une machine (sauvegarde l'état RAM) :

```bash
vagrant suspend web
```

Reprendre une machine en pause :

```bash
vagrant resume web
```

### Provisioning

Ré-exécuter les scripts de provisioning sans redémarrer :

```bash
vagrant provision web
```

### Snapshots (avec le plugin)

Si vous avez installé le plugin vagrant-vbox-snapshot :

```bash
# Créer un snapshot
vagrant snapshot save web web-snapshot-1

# Restaurer un snapshot
vagrant snapshot restore web web-snapshot-1

# Lister les snapshots
vagrant snapshot list web
```

## Scénarios d'Utilisation Courants

### Scénario 1 : Développement Web

1. Démarrer le serveur web et applicatif :
```bash
vagrant up web app
```

2. Accéder au serveur web depuis votre navigateur :
- URL : http://192.168.56.10

3. Déployer votre code sur le serveur :
```bash
vagrant ssh web
cd /var/www/html
# Déployez votre application
```

### Scénario 2 : Test de Base de Données

1. Démarrer uniquement le serveur de base de données :
```bash
vagrant up db
```

2. Se connecter à MySQL :
```bash
vagrant ssh db
sudo mysql -u root
```

### Scénario 3 : Infrastructure Complète

1. Démarrer toute l'infrastructure :
```bash
vagrant up
```

2. Vérifier que tout fonctionne :
```bash
vagrant status
```

3. Tester la connectivité entre les serveurs :
```bash
vagrant ssh web
ping 192.168.56.11  # Ping le serveur app
ping 192.168.56.12  # Ping le serveur db
```

## Personnalisation

### Modifier la Configuration des VMs

Pour modifier la RAM ou le nombre de CPUs, éditez le fichier `Vagrantfile` :

```ruby
web.vm.provider "virtualbox" do |vb|
  vb.memory = "4096"  # Augmenter à 4 GB
  vb.cpus = 4         # Augmenter à 4 CPUs
end
```

Ensuite, rechargez la configuration :

```bash
vagrant reload web
```

### Ajouter des Provisioners Personnalisés

Ajoutez vos propres scripts de provisioning dans le Vagrantfile :

```ruby
web.vm.provision "shell", inline: <<-SHELL
  # Vos commandes personnalisées ici
  apt-get install -y git
SHELL
```

### Synchronisation des Dossiers

Par défaut, le dossier du projet est synchronisé avec `/vagrant` sur chaque VM.

Pour ajouter d'autres dossiers synchronisés :

```ruby
web.vm.synced_folder "./html", "/var/www/html"
```

## Résolution de Problèmes

### La VM ne démarre pas

```bash
# Vérifier les logs
vagrant up web --debug

# Essayer de détruire et recréer
vagrant destroy web -f
vagrant up web
```

### Problèmes de Réseau

```bash
# Vérifier la configuration réseau
vagrant ssh web
ip addr show

# Redémarrer le réseau
sudo systemctl restart networking
```

### Manque d'Espace Disque

```bash
# Nettoyer les boxes inutilisées
vagrant box prune

# Supprimer les VMs orphelines
vagrant global-status --prune
```

## Bonnes Pratiques

1. **Sauvegardes régulières** : Créez des snapshots avant les modifications importantes
2. **Documentation** : Documentez toutes les modifications du Vagrantfile
3. **Version Control** : Gardez le Vagrantfile sous contrôle de version (Git)
4. **Ressources** : Ne démarrez que les VMs dont vous avez besoin
5. **Nettoyage** : Détruisez les VMs de test quand vous ne les utilisez plus

## Commandes Utiles

```bash
# Afficher la configuration SSH
vagrant ssh-config web

# Exécuter une commande à distance
vagrant ssh web -c "uptime"

# Voir les logs de provisioning
vagrant up web --provision-with shell

# Mettre à jour la box de base
vagrant box update
```

## Support et Documentation Supplémentaire

- Documentation officielle Vagrant : https://www.vagrantup.com/docs
- VirtualBox Documentation : https://www.virtualbox.org/manual/
- Pour les problèmes spécifiques, consultez le fichier [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
