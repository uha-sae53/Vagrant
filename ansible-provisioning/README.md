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



## Configuration d'ArgoCD (fichier vars/main.yml)

Pour que le rôle ArgoCD fonctionne correctement, vous devez configurer les accès à vos dépôts GitHub et déclarer les repositories à synchroniser dans le fichier :

```
ansible-provisioning/roles/argocd/vars/main.yml
```

Exemple de contenu :

```yaml
github_username: "votre_nom_utilisateur_github"
github_token: "votre_token_github_personnel"
github_email: "votre_email_github"

# Liste des repositories à déclarer dans ArgoCD
argocd_repos:
    - { name: vagrant, url: "https://github.com/uha-sae53/Vagrant.git" }
    - { name: frontend, url: "https://github.com/uha-sae53/Frontend.git" }
    - { name: api-catalogue, url: "https://github.com/uha-sae53/api-catalogue.git" }
    - { name: api-panier, url: "https://github.com/uha-sae53/api-panier.git" }
    - { name: api-commandes, url: "https://github.com/uha-sae53/api-commandes.git" }
    - { name: api-clients, url: "https://github.com/uha-sae53/api-clients.git" }
```

> **Attention** :
> - Le token GitHub doit avoir accès en lecture aux dépôts privés si nécessaire.
> - Ce fichier doit être présent et correctement rempli avant de lancer le provisionnement.