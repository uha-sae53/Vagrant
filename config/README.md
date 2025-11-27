# Configuration du Cluster Kubernetes

Ce répertoire contient tous les fichiers de configuration et scripts nécessaires au déploiement automatique du cluster Kubernetes.

## Structure

```
config/
├── README.md                 # Ce fichier
├── sysctl-k8s.conf          # Configuration réseau pour Kubernetes
├── prepare-system.sh        # Préparation du système (swap, modules kernel)
├── install-docker.sh        # Installation de Docker et containerd
├── install-k8s.sh           # Installation de Kubernetes (kubelet, kubeadm, kubectl)
├── init-master.sh           # Initialisation du nœud master
└── join-worker.sh           # Jonction des workers au cluster
```

## Description des fichiers

### sysctl-k8s.conf
Configuration système pour le réseau Kubernetes :
- Activation du bridge netfilter
- Activation du forwarding IP

### prepare-system.sh
Prépare le système pour Kubernetes :
- Désactive le swap (requis par Kubernetes)
- Charge les modules kernel nécessaires
- Applique la configuration sysctl

### install-docker.sh
Installe Docker et configure containerd :
- Ajoute le repository Docker officiel
- Installe Docker CE, containerd
- Configure containerd avec SystemdCgroup pour Kubernetes

### install-k8s.sh
Installe les composants Kubernetes :
- Ajoute le repository Kubernetes officiel (v1.28)
- Installe kubelet, kubeadm, kubectl
- Verrouille les versions pour éviter les mises à jour automatiques

### init-master.sh
Initialise le nœud master du cluster :
- Exécute `kubeadm init` avec les bons paramètres
- Configure kubectl pour l'utilisateur vagrant
- Installe Flannel (CNI)
- Génère le token de jonction (24h) pour les workers
- Crée le fichier flag `.master-ready`

### join-worker.sh
Fait rejoindre un worker au cluster :
- Attend que le master soit complètement initialisé
- Vérifie la présence du fichier `join.sh`
- Attend la propagation du token (15s)
- Exécute la commande de jonction au cluster

## Utilisation

Ces scripts sont automatiquement appelés par `provision.sh` dans l'ordre approprié :

1. **Tous les nœuds** (master et workers) :
   - `prepare-system.sh`
   - `install-docker.sh`
   - `install-k8s.sh`

2. **Master uniquement** :
   - `init-master.sh`

3. **Workers uniquement** :
   - `join-worker.sh`

## Avantages de cette approche

- **Modularité** : Chaque script a une responsabilité claire
- **Réutilisabilité** : Scripts peuvent être utilisés séparément si besoin
- **Maintenance** : Plus facile de modifier une configuration spécifique
- **Lisibilité** : Le fichier `provision.sh` devient plus court et clair
- **Testabilité** : Chaque script peut être testé indépendamment

## Paramètres configurables

### Master IP
Définie dans `init-master.sh` :
```bash
MASTER_IP="192.168.56.10"
```

### Pod Network CIDR
Définie dans `init-master.sh` :
```bash
--pod-network-cidr=10.244.0.0/16
```

### Version Kubernetes
Définie dans `install-k8s.sh` :
```bash
https://pkgs.k8s.io/core:/stable:/v1.28/deb/
```

### Timeout Worker
Défini dans `join-worker.sh` :
```bash
if [ $WAIT_COUNT -gt 600 ]; then  # 10 minutes
```

## Notes

- Tous les scripts utilisent `set -e` pour arrêter l'exécution en cas d'erreur
- Les scripts sont conçus pour être idempotents autant que possible
- Les logs sont clairs avec des préfixes [Master]/[Worker]/[Docker]/[K8s]/[Système]
