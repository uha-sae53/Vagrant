# Configuration ArgoCD

## Token GitHub

Pour que ArgoCD puisse accéder aux repos privés, vous devez configurer un token GitHub valide avec les droits suivants :

- `repo` (Full control of private repositories)
- `read:packages` (Read packages from GitHub Container Registry)

### Mise à jour du token

Éditez le fichier `roles/argocd/vars/main.yml` et modifiez les variables suivantes :

```yaml
github_username: "votre-username"
github_token: "votre-token-github"
github_email: "votre-email@example.com"
```

Puis relancez le provisionnement :

```bash
vagrant provision vm-master
```

### Vérification

Pour vérifier que les secrets sont bien créés :

```bash
vagrant ssh vm-master
kubectl get secrets -n argocd | grep argo-repo
kubectl get applications -n argocd
```

Les applications doivent être en état `Synced` et `Healthy`.
