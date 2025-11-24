# Vagrant
Répertoire des Vagrantfile pour l'infrastructure

## Objectif
Ce Vagrantfile permet de déployer automatiquement une infrastructure composée de 3 machines virtuelles pour le projet SAE e-commerce.

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

Pour démarrer l'infrastructure :

```bash
vagrant up
```

Pour arrêter les machines virtuelles :

```bash
vagrant halt
```

Pour supprimer l'infrastructure :

```bash
vagrant destroy
```

## Explication du script `provision.sh`

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
  - `sed` : Éditeur de flux pour modifier des fichiers
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


