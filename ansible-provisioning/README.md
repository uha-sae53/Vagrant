# Provisionnement Ansible pour le cluster Kubernetes

Cette version utilise Ansible au lieu des scripts shell pour provisionner exactement le même cluster Kubernetes.

## Structure

```
ansible-provisioning/
├── Vagrantfile                    # Vagrantfile configuré pour Ansible
├── ansible.cfg                    # Configuration Ansible
├── inventory.ini                  # Inventaire des machines
├── playbook.yml                   # Playbook principal
└── roles/
    ├── system-prepare/            # Équivalent: prepare-system.sh
    │   ├── tasks/main.yml
    │   └── files/sysctl-k8s.conf
    ├── docker/                    # Équivalent: install-docker.sh
    │   └── tasks/main.yml
    ├── kubernetes/                # Équivalent: install-k8s.sh
    │   └── tasks/main.yml
    ├── k8s-master/                # Équivalent: init-master.sh
    │   └── tasks/main.yml
    ├── k8s-worker/                # Équivalent: join-worker.sh
    │   └── tasks/main.yml
    └── k8s-dashboard/             # Équivalent: install-dashboard.sh
        └── tasks/main.yml
```

## Fonctionnalités identiques

 Désactivation du swap  
 Configuration réseau (br_netfilter, sysctl)  
 Installation de Docker avec containerd  
 Installation de Kubernetes (v1.28)  
 Initialisation du master avec kubeadm  
 Installation de Flannel  
 Configuration du StorageClass local-path par défaut  
 Création du secret GitHub Container Registry  
 Jonction des workers au cluster  
 Installation du Dashboard Kubernetes avec Helm  
 Application automatique des manifests  

## Utilisation

```bash
cd ansible-provisioning
vagrant up
```

