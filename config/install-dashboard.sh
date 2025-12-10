#!/bin/bash

set -e

echo "[Dashboard] Installation de Helm..."
sudo apt-get install curl gpg apt-transport-https --yes
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list 
sudo apt-get update
sudo apt-get install helm

if [ $? -ne 0 ]; then
    echo "[Dashboard] Échec de l'installation de Helm."
    exit 1
fi
echo "[Dashboard] Helm installé avec succès."

echo "[Dashboard] Déploiement du tableau de bord Kubernetes..."
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

if [ $? -ne 0 ]; then
    echo "[Dashboard] Échec du déploiement du tableau de bord Kubernetes."
    exit 1
fi
echo "[Dashboard] Tableau de bord Kubernetes déployé avec succès."

echo "[Dashboard] Configuration de l'accès au tableau de bord..."

kubectl -n kubernetes-dashboard patch svc kubernetes-dashboard-kong-proxy \
  -p '{
    "spec": {
      "type": "NodePort",
      "ports": [
        {"port": 80, "targetPort": 80, "nodePort": 30080},
        {"port": 443, "targetPort": 443, "nodePort": 30443}
      ]
    }
  }'

if [ $? -ne 0 ]; then
    echo "[Dashboard] Échec de la configuration de l'accès au tableau de bord."
    exit 1
fi
echo "[Dashboard] Accès au tableau de bord configuré avec succès."

echo "[Dashboard] Vérification du type..."
kubectl -n kubernetes-dashboard get svc kubernetes-dashboard-kong-proxy
if [ $? -ne 0 ]; then
    echo "[Dashboard] Échec de la vérification du type."
    exit 1
fi

echo "[Dashboard] Vérification que le service est de type NodePort..."
if kubectl -n kubernetes-dashboard get svc kubernetes-dashboard-kong-proxy -o jsonpath='{.spec.type}' | grep -q "NodePort"; then
    echo "[Dashboard] Le service est bien configuré en NodePort."
else
    echo "[Dashboard] Erreur: Le service n'est pas de type NodePort."
    exit 1
fi

echo "[Dashboard] Configuration de l'utilisateur administrateur..."
kubectl create serviceaccount admin-user -n kubernetes-dashboard
kubectl create clusterrolebinding admin-user-binding --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:admin-user
if [ $? -ne 0 ]; then
    echo "[Dashboard] Échec de la configuration de l'utilisateur administrateur."
    exit 1
fi
echo "[Dashboard] Utilisateur administrateur configuré avec succès."

echo "[Dashboard] Récupération du token d'accès..."
TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user)
if [ $? -ne 0 ]; then
    echo "[Dashboard] Échec de la récupération du token d'accès."
    exit 1
fi
echo "[Dashboard] Token d'accès récupéré avec succès :"

echo "Veuillez utiliser le token suivant pour vous connecter au tableau de bord Kubernetes :"
echo ""
echo "https://<ip>:30080"
echo ""
echo "Token : $TOKEN"