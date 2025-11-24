# Architecture de l'Infrastructure

## Vue d'ensemble

Cette infrastructure déploie 3 machines virtuelles interconnectées pour simuler un environnement de production complet.

## Schéma d'Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Machine Hôte                          │
│                                                          │
│  ┌───────────────┐  ┌───────────────┐  ┌──────────────┐│
│  │ Port 8080     │  │ Port 3306     │  │ Port 8000    ││
│  └───────┬───────┘  └───────┬───────┘  └──────┬───────┘│
│          │                  │                  │        │
│          ▼                  ▼                  ▼        │
│  ┌───────────────┐  ┌───────────────┐  ┌──────────────┐│
│  │   VM Web      │  │    VM DB      │  │   VM App     ││
│  │               │  │               │  │              ││
│  │ 192.168.56.10 │  │ 192.168.56.11 │  │192.168.56.12 ││
│  │               │  │               │  │              ││
│  │ Apache2       │  │ MySQL Server  │  │ Node.js 18   ││
│  │ Port 80       │  │ Port 3306     │  │ Port 8000    ││
│  │ 1 GB RAM      │  │ 2 GB RAM      │  │ 1 GB RAM     ││
│  │ 1 CPU         │  │ 2 CPUs        │  │ 1 CPU        ││
│  └───────┬───────┘  └───────┬───────┘  └──────┬───────┘│
│          │                  │                  │        │
│          └──────────────────┴──────────────────┘        │
│                   Réseau Privé                          │
│                  192.168.56.0/24                        │
└─────────────────────────────────────────────────────────┘
```

## Composants

### 1. Serveur Web (web)
- **Rôle** : Frontend / Serveur HTTP
- **Technologie** : Apache 2.4
- **Ressources** : 1 GB RAM, 1 CPU
- **Réseau** : 192.168.56.10
- **Services** : 
  - HTTP (port 80)
  - SSH (port 22)

### 2. Serveur Base de Données (db)
- **Rôle** : Persistance des données
- **Technologie** : MySQL 8.0
- **Ressources** : 2 GB RAM, 2 CPUs
- **Réseau** : 192.168.56.11
- **Services** :
  - MySQL (port 3306)
  - SSH (port 22)

### 3. Serveur Application (app)
- **Rôle** : Backend / API
- **Technologie** : Node.js 18.x
- **Ressources** : 1 GB RAM, 1 CPU
- **Réseau** : 192.168.56.12
- **Services** :
  - Application (port 8000)
  - SSH (port 22)

## Flux de Communication

```
Client (Navigateur)
    │
    ▼
localhost:8080 ───────► VM Web (Apache)
                           │
                           ▼
                        VM App (Node.js) ◄──► VM DB (MySQL)
                           │
                           ▼
                     localhost:8000
```

### Scénario Typique

1. **Client** accède à l'application via http://localhost:8080
2. **VM Web** sert les fichiers statiques (HTML, CSS, JS)
3. **Client** fait des requêtes API vers localhost:8000
4. **VM App** traite les requêtes et interroge la base de données
5. **VM DB** retourne les données à l'application
6. **VM App** renvoie la réponse au client

## Réseau

### Réseau Privé Host-Only
- **Plage** : 192.168.56.0/24
- **Usage** : Communication inter-VMs
- **Avantage** : Isolation du réseau externe

### Port Forwarding
| VM | Port Interne | Port Hôte | Service |
|----|--------------|-----------|---------|
| web | 80 | 8080 | HTTP |
| db | 3306 | 3306 | MySQL |
| app | 8000 | 8000 | Application |

## Extensibilité

Cette architecture peut être facilement étendue :

- **Load Balancer** : Ajouter une VM nginx en reverse proxy
- **Réplication DB** : Ajouter une VM pour MySQL replica
- **Cache** : Ajouter une VM Redis ou Memcached
- **Monitoring** : Ajouter une VM avec Prometheus/Grafana

## Sécurité

### Mesures Implémentées
- Réseau privé isolé
- Accès SSH sécurisé
- Ports exposés uniquement sur localhost

### Améliorations Possibles
- Configurer un firewall (ufw)
- Implémenter SSL/TLS
- Configurer l'authentification MySQL
- Mettre en place des certificats SSH

## Performance

### Ressources Totales Requises
- **RAM** : 4 GB (1 + 2 + 1)
- **CPU** : 4 cores (1 + 2 + 1)
- **Disque** : ~10 GB pour les 3 VMs

### Optimisations
- Ajuster la RAM selon vos besoins
- Utiliser des disques SSD pour l'hôte
- Limiter le nombre de VMs actives simultanément
