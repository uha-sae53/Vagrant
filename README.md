# Vagrant
Répertoire des Vagrantfile pour l'infrastructure

## Objectif
Ce Vagrantfile permet de déployer automatiquement une infrastructure composée de 3 machines virtuelles pour le projet SAE e-commerce.

## Structure du répertoire

```
Vagrant/
├── Vagrantfile              # Configuration des VMs
├── provision.sh             # Script principal de provisioning (orchestrateur)
├── config/                  # Fichiers de configuration préfabriqués
│   ├── README.md           # Documentation des scripts de configuration
│   ├── sysctl-k8s.conf     # Configuration réseau Kubernetes
│   ├── prepare-system.sh   # Préparation du système
│   ├── install-docker.sh   # Installation de Docker
│   ├── install-k8s.sh      # Installation de Kubernetes
│   ├── init-master.sh      # Initialisation du master
│   └── join-worker.sh      # Jonction des workers
└── docker/                  # Configuration Docker Compose pour les services
    └── docker-compose.yml
```

### Architecture modulaire

Le provisioning utilise maintenant une **architecture modulaire** :

- **`provision.sh`** : Script orchestrateur qui appelle les scripts de configuration
- **`config/`** : Répertoire contenant tous les scripts et fichiers de configuration
  - Chaque script a une responsabilité unique et claire
  - Facilite la maintenance et les modifications
  - Permet de réutiliser les scripts indépendamment


## Installation de Vagrant
Instructions pour installer Vagrant sur différentes plateformes : https://www.vagrantup.com/docs/installation

## Modules utilisés pour le déploiement de l'infrastructure

Installation du plugin vagrant-reload (permet de redémarrer une VM durant le provisioning) :

```bash
vagrant plugin install vagrant-reload
Education Benefits
You have a current student coupon applied. Find more information on your benefits here!
￼
Start an application
Coupon applied
Expires in almost 2 years
Approved on December 09, 2025
Application Type: Student

```

Installation du module pour utiliser Vagrant sur QEMU/KVM :

```bash
vagrant plugin install vagrant-libvirt
```

### 📝 Utilisation manuelle avec Vagrant

Pour démarrer l'infrastructure manuellement :

```bash
# Démarrer uniquement le master
vagrant up vm-master

# Attendre que le master soit complètement initialisé (30-60 secondes)
# Puis démarrer les workers
vagrant up vm-slave-1 vm-slave-2
```

**Important** : Ne pas utiliser `vagrant up` sans arguments car cela démarre les VMs en parallèle, ce qui peut causer des erreurs de jonction des workers (token expiré ou non disponible).

Pour arrêter les machines virtuelles :

```bash
vagrant halt
```

Pour supprimer l'infrastructure :

```bash
vagrant destroy -f
```

### Vérifier le cluster

Une fois toutes les VMs démarrées, vérifiez l'état du cluster :

```bash
vagrant ssh vm-master -c 'kubectl get nodes'
```

Vous devriez voir les 3 nœuds en état `Ready` :
```
NAME       STATUS   ROLES           AGE   VERSION
master     Ready    control-plane   2m    v1.28.x
slave-1    Ready    <none>          1m    v1.28.x
slave-2    Ready    <none>          1m    v1.28.x
```

### Vérifier les logs de provisioning

```bash
# Logs du master
vagrant ssh vm-master -c 'sudo journalctl -u kubelet -f'

# Logs d'un worker
vagrant ssh vm-slave-1 -c 'sudo journalctl -u kubelet -f'
```

## Explication du script `provision.sh`

Le script `provision.sh` est maintenant un **orchestrateur léger** qui appelle les scripts modulaires du répertoire `config/`.

### Scripts de configuration (répertoire `config/`)

Consultez le fichier [`config/README.md`](config/README.md) pour la documentation détaillée de chaque script.

**Résumé** :
- **`prepare-system.sh`** : Désactive le swap, configure les modules kernel et paramètres réseau
- **`install-docker.sh`** : Installe Docker CE et configure containerd pour Kubernetes
- **`install-k8s.sh`** : Installe kubelet, kubeadm et kubectl (version 1.28)
- **`init-master.sh`** : Initialise le cluster, installe Flannel, génère le token pour les workers
- **`join-worker.sh`** : Attend le master et fait rejoindre le worker au cluster

### Avantages de cette architecture

1. **Modularité** : Chaque script a une responsabilité unique
2. **Réutilisabilité** : Les scripts peuvent être utilisés indépendamment
3. **Maintenance facilitée** : Modification d'un seul script sans toucher aux autres
4. **Lisibilité** : Le fichier `provision.sh` est clair et concis
5. **Testabilité** : Chaque script peut être testé séparément

### Résumé des commandes Linux utilisées

| Commande | Usage |
|----------|-------|
| `apt-get update` | Met à jour la liste des paquets disponibles |
| `apt-get install -y` | Installe des paquets sans confirmation interactive |
| `apt-mark hold` | Verrouille la version d'un paquet pour empêcher les mises à jour |
| `sed -i` | Modifie un fichier en place avec des expressions régulières |
| `systemctl enable` | Active le démarrage automatique d'un service au boot |
| `systemctl restart` | Redémarre un service systemd |
| `modprobe` | Charge des modules dans le kernel Linux |
| `curl -fsSL` | Télécharge des fichiers de manière robuste et silencieuse |
| `chmod` | Modifie les permissions d'accès aux fichiers |
| `chown` | Change le propriétaire et/ou le groupe d'un fichier |
| `sysctl --system` | Recharge tous les paramètres kernel depuis `/etc/sysctl.d/` |


