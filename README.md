# Vagrant - Infrastructure Kubernetes avec Ansible

Répertoire des Vagrantfile pour l'infrastructure du projet SAE e-commerce. 

## Prérequis matériels et système

Toutes les opérations décrites dans ce guide doivent être réalisées sur un environnement **Debian** disposant d'au moins **16 Go de RAM**. Cette configuration est recommandée pour garantir des performances optimales lors du déploiement de l'infrastructure. 

## Objectif

Ce projet permet de déployer automatiquement une infrastructure composée de 3 machines virtuelles formant un cluster Kubernetes, en utilisant **Ansible** pour le provisioning automatisé. 

## Architecture du projet

```
Vagrant/
├── README. md                      # Cette documentation
├── ansible-provisioning/          # Architecture principale (Ansible)
│   ├── Vagrantfile               # Configuration des VMs
│   ├── ansible.cfg               # Configuration Ansible
│   ├── inventory.ini             # Inventaire des machines
│   ├── playbook.yml              # Playbook principal
│   ├── manifests/                # Manifests Kubernetes
│   └── roles/                    # Rôles Ansible modulaires
│       ├── system-prepare/       # Préparation du système
│       ├── docker/               # Installation de Docker
│       ├── kubernetes/           # Installation de Kubernetes
│       ├── k8s-master/           # Initialisation du master
│       ├── k8s-worker/           # Jonction des workers
│       └── k8s-dashboard/        # Dashboard Kubernetes
├── shell-provisioning/           # DÉPRÉCIÉ - Scripts shell (tests uniquement)
└── docker/                       # Configuration Docker Compose
```

### Note importante sur le shell-provisioning

Le répertoire `shell-provisioning/` contient l'ancienne architecture basée sur des scripts shell.  **Cette approche est désormais dépréciée et n'est plus maintenue**. Elle a été conservée uniquement à des fins de tests et de référence. 

**Utilisez exclusivement le répertoire `ansible-provisioning/` pour déployer l'infrastructure.**

## Installation des prérequis

### 1. Installation de GCC et outils de compilation

```bash
sudo apt update
sudo apt install -y build-essential gcc make ruby-dev libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ebtables dnsmasq-base
```

### 2. Installation de KVM/QEMU

```bash
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
```

1. Ajouter votre utilisateur au groupe libvirt

```bash
sudo usermod -aG libvirt $(whoami)

#Appliquer les changements de groupe sans se déconnecter
newgrp libvirt
```
Remarque : Après avoir exécuté ces commandes, il peut être nécessaire de redémarrer votre session ou votre machine pour que les changements prennent pleinement effet.

### 3. Installation de Vagrant

Instructions officielles :  https://www.vagrantup.com/docs/installation

Pour Debian/Ubuntu :
```bash
# Télécharger et ajouter la clé GPG de HashiCorp
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Ajouter le dépôt HashiCorp à la liste des sources (corriger l'URL)
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Mettre à jour les informations des paquets
sudo apt update

# Installer Vagrant
sudo apt install vagrant
```

### 4. Installation des plugins Vagrant

```bash
# Plugin pour redémarrer les VMs durant le provisioning
vagrant plugin install vagrant-reload

# Plugin pour utiliser Vagrant avec QEMU/KVM
vagrant plugin install vagrant-libvirt
```

### 5. Installation d'Ansible

Ansible est utilisé pour automatiser le provisioning du cluster Kubernetes.

#### Installation sur Debian/Ubuntu

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
```

#### Installation via pip (méthode alternative)

```bash
sudo apt install -y python3-pip
pip3 install ansible
```

#### Vérification de l'installation

```bash
ansible --version
```

Vous devriez voir une version >= 2.9. 


### 6. Installation du serveur NFS (OBLIGATOIRE)

**IMPORTANT** : Le serveur NFS est **obligatoire** sur la **machine hôte** (celle qui lance Vagrant) pour le partage de fichiers entre l'hôte et les VMs.  Le Vagrantfile utilise `type: "nfs"` pour synchroniser le répertoire courant.

#### Installation sur la machine hôte (Debian/Ubuntu)

```bash
sudo apt update
sudo apt install -y nfs-kernel-server nfs-common
```

#### Vérification

```bash
# Vérifier que le service NFS est actif
sudo systemctl status nfs-server

# Si le service n'est pas démarré
sudo systemctl enable --now nfs-server
```

#### Configuration des exports NFS (automatique)

Vagrant configure automatiquement les exports NFS dans `/etc/exports` lors du `vagrant up`. Vous n'avez rien à faire manuellement.

#### Résolution de problèmes NFS

| Erreur | Solution |
|--------|----------|
| `mount.nfs: Connection timed out` | Vérifier que `nfs-server` est actif sur l'hôte :  `sudo systemctl start nfs-server` |
| `exportfs: No such file or directory` | Installer `nfs-kernel-server` sur l'hôte |
| `Permission denied` | Vérifier les droits sur le répertoire partagé :  `sudo chmod -R 755 . ` |
| `mount.nfs: access denied` | Vérifier le firewall : `sudo ufw allow from 192.168.56.0/24` |

## Configuration du réseau libvirt

Avant de lancer les VMs, il faut créer un réseau libvirt correspondant à la plage d'adresses utilisée par le Vagrantfile (`192.168.56.0/24`).

### Vérifier les réseaux existants

```bash
sudo virsh net-list --all
```

### Créer le réseau vagrant-libvirt

Créez un fichier de définition du réseau :

```bash
cat <<EOF | sudo tee /etc/libvirt/qemu/networks/vagrant-libvirt.xml
<network>
  <name>vagrant-libvirt</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr2' stp='on' delay='0'/>
  <ip address='192.168.56.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.56.2' end='192.168.56.254'/>
    </dhcp>
  </ip>
</network>
EOF
```

Puis activez le réseau :

```bash
# Définir le réseau
sudo virsh net-define /etc/libvirt/qemu/networks/vagrant-libvirt.xml

# Démarrer le réseau
sudo virsh net-start vagrant-libvirt

# Activer le démarrage automatique au boot
sudo virsh net-autostart vagrant-libvirt
```

### Vérification

Après ces commandes, vérifiez que le réseau est bien actif :

```bash
sudo virsh net-list --all
```

Vous devriez voir :  

```
 Name              State    Autostart   Persistent
----------------------------------------------------
 vagrant-libvirt   active   yes         yes
```

### Résolution de problèmes courants

| Erreur | Solution |
|--------|----------|
| `Network not found:  no network with matching name 'network'` | Créer le réseau avec les commandes ci-dessus |
| `error: Failed to start network` | Vérifier que libvirtd est démarré : `sudo systemctl start libvirtd` |
| `network is not active` | Démarrer le réseau : `sudo virsh net-start vagrant-libvirt` |
| `Address already in use` | Un autre réseau utilise déjà cette plage.  Supprimez-le ou modifiez l'adresse |

## Reboot de la machine hôte
Après avoir installé KVM/libvirt et configuré le réseau, il est recommandé de redémarrer la machine hôte pour s'assurer que tous les services sont correctement initialisés.

```bash
sudo reboot
```

### Installation et vérifications Git

Installer Git
```bash
sudo apt install git -y
```
Cloner le repository
```bash
git clone https://github.com/uha-sae53/Vagrant.git && cd Vagrant/
```

# Configuration de ArgoCD

Configuration d'ArgoCD (fichier vars/main.yml)
Pour que le rôle ArgoCD fonctionne correctement, vous devez configurer les accès à vos dépôts GitHub et déclarer les repositories à synchroniser dans le fichier :

 Copier le fichier :
```bash
cp ansible-provisioning/roles/argocd/vars/main.temp ansible-provisioning/roles/argocd/vars/main.yml
```

Exemple de contenu :
```bash
github_username: "votre_nom_utilisateur_github"
github_token: "votre_token_github_personnel"
github_email: "votre_email_github"

### Liste des repositories à déclarer dans ArgoCD
argocd_repos:
    - { name: vagrant, url: "https://github.com/uha-sae53/Vagrant.git" }
    - { name: frontend, url: "https://github.com/uha-sae53/Frontend.git" }
    - { name: api-catalogue, url: "https://github.com/uha-sae53/api-catalogue.git" }
    - { name: api-panier, url: "https://github.com/uha-sae53/api-panier.git" }
    - { name: api-commandes, url: "https://github.com/uha-sae53/api-commandes.git" }
    - { name: api-clients, url: "https://github.com/uha-sae53/api-clients.git" }
```
Attention :
Le token GitHub doit avoir accès en lecture aux dépôts privés si nécessaire.
Ce fichier doit être présent et correctement rempli avant de lancer le provisionnement.


## Déploiement de l'infrastructure

### Démarrage du cluster complet

```bash
cd ansible-provisioning
vagrant up
```

Cette commande démarre automatiquement les 3 VMs et exécute le provisioning Ansible :  
- `vm-master` : Nœud master Kubernetes (192.168.56.10)
- `vm-slave-1` : Worker node 1 (192.168.56.11)
- `vm-slave-2` : Worker node 2 (192.168.56.12)

### Commandes utiles

```bash
# Vérifier l'état des VMs
vagrant status

# Se connecter à une VM
vagrant ssh vm-master
vagrant ssh vm-slave-1
vagrant ssh vm-slave-2

# Arrêter les VMs
vagrant halt

# Redémarrer les VMs
vagrant reload

# Supprimer l'infrastructure
vagrant destroy -f

# Re-provisionner sans détruire
vagrant provision
```

## Vérification du cluster Kubernetes

### Vérifier l'état des nœuds

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

### Vérifier les pods système

```bash
vagrant ssh vm-master -c 'kubectl get pods -A'
```

### Vérifier les logs de kubelet

```bash
# Logs du master
vagrant ssh vm-master -c 'sudo journalctl -u kubelet -f'

# Logs d'un worker
vagrant ssh vm-slave-1 -c 'sudo journalctl -u kubelet -f'
```

## Architecture du provisioning Ansible

Le provisioning utilise une **architecture modulaire basée sur des rôles Ansible** :

### Rôles Ansible

| Rôle | Description | Équivalent shell |
|------|-------------|------------------|
| **system-prepare** | Désactive le swap, configure les modules kernel et paramètres réseau | `prepare-system.sh` |
| **docker** | Installe Docker CE et configure containerd pour Kubernetes | `install-docker.sh` |
| **kubernetes** | Installe kubelet, kubeadm et kubectl (version 1.28) | `install-k8s.sh` |
| **k8s-master** | Initialise le cluster, installe Flannel, génère le token pour les workers | `init-master.sh` |
| **k8s-worker** | Attend le master et fait rejoindre le worker au cluster | `join-worker.sh` |
| **k8s-dashboard** | Installe le Dashboard Kubernetes avec Helm | `install-dashboard.sh` |

### Avantages de l'architecture Ansible

1. **Idempotence** : Les playbooks peuvent être réexécutés sans effets secondaires
2. **Modularité** :  Chaque rôle a une responsabilité unique et claire
3. **Réutilisabilité** : Les rôles peuvent être utilisés dans d'autres projets
4. **Maintenabilité** :  Modification d'un seul rôle sans toucher aux autres
5. **Lisibilité** : Syntaxe YAML claire et déclarative
6. **Testabilité** : Chaque rôle peut être testé séparément
7. **Gestion des erreurs** : Meilleure gestion des erreurs et des retries

## Paramètres configurables

### Adresses IP des VMs

Définies dans le `Vagrantfile` et `inventory.ini` :
- Master : `192.168.56.10`
- Worker 1 : `192.168.56.11`
- Worker 2 : `192.168.56.12`

### Version Kubernetes

Définie dans le rôle `kubernetes` : **v1.28**

### Pod Network CIDR

Définie dans le rôle `k8s-master` : `10.244.0.0/16` (Flannel)

### Ressources des VMs

Configurables dans le `Vagrantfile` :
- Master : 2 CPUs, 2048 MB RAM
- Workers : 2 CPUs, 2048 MB RAM

### Synchronisation NFS

Le Vagrantfile configure automatiquement : 
- **Type** : NFS version 4
- **Protocole** : TCP (UDP désactivé)
- **Répertoire partagé** : `.` (répertoire courant) → `/vagrant` dans les VMs

## Ressources et documentation

- [Documentation Kubernetes](https://kubernetes.io/docs/home/)
- [Documentation Ansible](https://docs.ansible.com/)
- [Documentation Vagrant](https://www.vagrantup.com/docs)
- [Documentation Flannel CNI](https://github.com/flannel-io/flannel)

## Résumé des commandes principales

| Commande | Usage |
|----------|-------|
| `vagrant up` | Démarre et provisionne les VMs |
| `vagrant halt` | Arrête les VMs |
| `vagrant destroy -f` | Supprime complètement les VMs |
| `vagrant ssh vm-master` | Se connecte au master |
| `vagrant provision` | Re-exécute le provisioning Ansible |
| `vagrant reload` | Redémarre les VMs |
| `ansible-playbook playbook.yml` | Exécute le playbook manuellement |

## Support

Pour toute question ou problème, consultez les logs :  
```bash
vagrant ssh vm-master -c 'sudo journalctl -u kubelet -n 100'
```
