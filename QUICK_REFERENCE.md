# Référence Rapide Vagrant

## Commandes Essentielles

### Gestion des VMs

```bash
vagrant up                 # Démarrer toutes les VMs
vagrant up web            # Démarrer une VM spécifique
vagrant halt              # Arrêter toutes les VMs
vagrant halt web          # Arrêter une VM spécifique
vagrant reload            # Redémarrer les VMs
vagrant destroy           # Détruire toutes les VMs
vagrant destroy web       # Détruire une VM spécifique
```

### Connexion et État

```bash
vagrant ssh web           # Se connecter à une VM
vagrant status            # État des VMs du projet
vagrant global-status     # État de toutes les VMs Vagrant
```

### Provisioning

```bash
vagrant provision         # Ré-exécuter le provisioning
vagrant reload --provision # Redémarrer avec provisioning
```

## Architecture Quick View

| VM  | IP            | RAM  | CPU | Services     |
|-----|---------------|------|-----|--------------|
| web | 192.168.56.10 | 2 GB | 2   | Nginx        |
| app | 192.168.56.11 | 3 GB | 2   | Python       |
| db  | 192.168.56.12 | 4 GB | 2   | MySQL        |

## Dépannage Express

### VM ne démarre pas
```bash
vagrant destroy web -f && vagrant up web
```

### Problème réseau
```bash
vagrant reload web
```

### Voir les logs détaillés
```bash
vagrant up web --debug
```

### Nettoyer l'environnement
```bash
vagrant destroy -f
vagrant box prune
vagrant global-status --prune
```

## Accès aux Services

### Nginx (Web Server)
```bash
http://192.168.56.10
vagrant ssh web -c "sudo systemctl status nginx"
```

### MySQL (DB Server)
```bash
vagrant ssh db -c "sudo mysql -u root"
```

### Python (App Server)
```bash
vagrant ssh app -c "python3 --version"
```

## Tests de Connectivité

```bash
# Depuis la machine hôte
ping 192.168.56.10
ping 192.168.56.11
ping 192.168.56.12

# Entre les VMs
vagrant ssh web -c "ping -c 3 192.168.56.11"
vagrant ssh app -c "ping -c 3 192.168.56.12"
```

## Ressources Requises

- RAM minimale : 10 GB
- Espace disque : 30 GB
- CPU : Support virtualisation (VT-x/AMD-V)

## Documentation Complète

- [Installation](docs/INSTALLATION.md)
- [Utilisation](docs/USAGE.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Dépannage](docs/TROUBLESHOOTING.md)
