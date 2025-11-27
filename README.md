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

**Avantages** :
- ✅ Meilleure organisation du code
- ✅ Facilité de maintenance
- ✅ Scripts réutilisables
- ✅ Configuration centralisée
- ✅ Plus facile à tester

## Installation de Vagrant
Instructions pour installer Vagrant sur différentes plateformes : https://www.vagrantup.com/docs/installation

## Modules utilisés pour le déploiement de l'infrastructure

Installation du plugin vagrant-reload (permet de redémarrer une VM durant le provisioning) :

```bash
vagrant plugin install vagrant-reload
```

Installation du module pour utiliser Vagrant sur QEMU/KVM :

```bash
vagrant plugin install vagrant-libvirt
```

## Utilisation

### 🚀 Utilisation avec le script d'aide (Recommandé)

Le script `cluster.sh` simplifie la gestion du cluster Kubernetes :

```bash
# Démarrer le cluster (master puis workers)
./cluster.sh up

# Vérifier le statut
./cluster.sh status

# Redémarrer le cluster
./cluster.sh restart

# Détruire le cluster
./cluster.sh destroy

# Se connecter au master
./cluster.sh ssh-master

# Se connecter aux workers
./cluster.sh ssh-worker1
./cluster.sh ssh-worker2

# Nettoyer les fichiers de jonction
./cluster.sh clean
```

**Avantage** : Le script garantit le bon ordre de démarrage (master d'abord, workers ensuite) et évite les problèmes de token expiré.

### 📝 Utilisation manuelle avec Vagrant

Pour démarrer l'infrastructure manuellement :

```bash
# Démarrer uniquement le master
vagrant up vm-master

# Attendre que le master soit complètement initialisé (30-60 secondes)
# Puis démarrer les workers
vagrant up vm-slave-1 vm-slave-2
```

⚠️ **Important** : Ne pas utiliser `vagrant up` sans arguments car cela démarre les VMs en parallèle, ce qui peut causer des erreurs de jonction des workers (token expiré ou non disponible).

Pour arrêter les machines virtuelles :

```bash
vagrant halt
```

Pour supprimer l'infrastructure :

```bash
vagrant destroy -f
```

### 🔍 Vérifier le cluster

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

## Dépannage

### Erreur : "could not find a JWS signature in the cluster-info ConfigMap"

Cette erreur se produit lorsque les workers tentent de rejoindre le cluster avant que le master ne soit complètement initialisé, ou si le token a expiré.

**Solution** :
1. Détruire et recréer le cluster avec le bon ordre :
   ```bash
   ./cluster.sh restart
   ```

2. Ou manuellement :
   ```bash
   vagrant destroy -f
   vagrant up vm-master
   # Attendre 30-60 secondes
   vagrant up vm-slave-1 vm-slave-2
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

### Structure simplifiée

```bash
#!/bin/bash
set -e

HOSTNAME=$(hostname)
CONFIG_DIR="/vagrant/config"

# Rendre tous les scripts exécutables
chmod +x $CONFIG_DIR/*.sh

# Étapes communes à tous les nœuds
bash $CONFIG_DIR/prepare-system.sh    # Préparation système
bash $CONFIG_DIR/install-docker.sh    # Installation Docker
bash $CONFIG_DIR/install-k8s.sh       # Installation Kubernetes

# Étapes spécifiques selon le type de nœud
if [[ "$HOSTNAME" == "master" ]]; then
    bash $CONFIG_DIR/init-master.sh   # Initialisation du master
elif [[ "$HOSTNAME" == slave-* ]]; then
    bash $CONFIG_DIR/join-worker.sh   # Jonction au cluster
fi
```

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

## Explication détaillée de l'ancien script (pour référence)

<details>
<summary>Cliquez pour voir l'explication détaillée de l'ancienne version monolithique</summary>

Ce script automatise l'installation et la configuration d'un cluster Kubernetes sur des machines Debian. Il s'exécute sur chaque machine virtuelle (master et workers) et adapte son comportement selon le hostname.

### Structure du script

#### **En-tête et variables**
```bash
#!/bin/bash
set -e  # Arrête le script si une commande échoue
```
- `set -e` : Mode "strict" qui stoppe l'exécution dès qu'une erreur survient

#### **[1] Configuration du système**

```bash
swapoff -a
sed -i '/swap/d' /etc/fstab
```
- **`swapoff -a`** : Désactive immédiatement la mémoire swap (requis par Kubernetes)
- **`sed -i '/swap/d' /etc/fstab`** :
  - `-i` : Modifie le fichier en place
  - `/swap/d` : Supprime toutes les lignes contenant "swap"
  - Rend la désactivation persistante au redémarrage

```bash
modprobe br_netfilter
```
- **`modprobe`** : Charge le module kernel `br_netfilter` nécessaire pour le réseau Kubernetes

```bash
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system
```
- Configure les paramètres réseau kernel
- **`sysctl --system`** : Recharge tous les fichiers de configuration système

#### **[2] Installation Docker**

```bash
apt-get update -qq
apt-get install -y apt-transport-https ca-certificates curl gnupg
```
- **`apt-get update`** : Met à jour la liste des paquets disponibles
  - `-qq` : Mode silencieux (minimal output)
- **`apt-get install -y`** : Installe des paquets
  - `-y` : Accepte automatiquement les confirmations
  - Installe les dépendances pour gérer les dépôts HTTPS

```bash
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
```
- **`install -m 0755 -d`** : Crée un répertoire avec permissions 755

</details>
- **`curl -fsSL`** : Télécharge la clé GPG Docker
  - `-f` : Échoue silencieusement en cas d'erreur HTTP
  - `-s` : Mode silencieux
  - `-S` : Affiche les erreurs même en mode silencieux
  - `-L` : Suit les redirections
- **`chmod a+r`** : Donne la permission de lecture à tous

```bash
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bullseye stable" > /etc/apt/sources.list.d/docker.list
```
- Ajoute le dépôt Docker officiel aux sources APT

```bash
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
```
- **`sed 's/ancien/nouveau/'`** : Remplace une chaîne par une autre
- Active le cgroup driver systemd (recommandé pour Kubernetes)

```bash
systemctl restart containerd
systemctl enable containerd
```
- **`systemctl restart`** : Redémarre le service
- **`systemctl enable`** : Active le démarrage automatique au boot

#### **[3] Installation Kubernetes**

```bash
apt-mark hold kubelet kubeadm kubectl
```
- **`apt-mark hold`** : Empêche la mise à jour automatique de ces paquets
- Garantit une version stable du cluster

#### **[4] Initialisation selon le type de nœud**

**Sur le Master :**
```bash
kubeadm init --apiserver-advertise-address="$MASTER_IP" --pod-network-cidr=10.244.0.0/16
```
- Initialise le cluster Kubernetes
- `--apiserver-advertise-address` : Adresse IP où l'API server écoute
- `--pod-network-cidr` : Plage réseau pour les pods (compatible Flannel)

```bash
mkdir -p /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
```
- Configure `kubectl` pour l'utilisateur vagrant
- **`chown`** : Change le propriétaire du fichier

```bash
kubeadm token create --print-join-command > /vagrant/join.sh
```
- Génère la commande de jonction pour les workers
- Stocke dans un fichier partagé entre VMs

**Sur les Workers :**
```bash
while [ ! -f /vagrant/join.sh ]; do
    sleep 2
done
bash /vagrant/join.sh
```
- Attend que le master génère `join.sh`
- Exécute la commande pour rejoindre le cluster

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


