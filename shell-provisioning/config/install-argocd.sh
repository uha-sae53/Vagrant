#!/bin/bash
# Installation d'ArgoCD pour le CD

set -e

export KUBECONFIG=/etc/kubernetes/admin.conf

echo "[ArgoCD] Création du namespace argocd..."
kubectl create namespace argocd || true

echo "[ArgoCD] Installation d'ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml || true
sleep 5
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml || true

echo "[ArgoCD] Attente du déploiement des pods ArgoCD..."
kubectl wait --for=condition=available --timeout=300s deployment --all -n argocd || true

echo "[ArgoCD] Configuration du service en NodePort sur le port 30808..."
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort","ports":[{"port":443,"targetPort":8080,"nodePort":30808}]}}'

echo "[ArgoCD] Récupération du mot de passe admin..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "=========================================="
echo "ArgoCD installé avec succès"
echo "=========================================="
echo ""
echo "URL d'accès : https://192.168.56.10:30808"
echo ""
echo "Login : admin"
echo "Password : $ARGOCD_PASSWORD"
echo ""
