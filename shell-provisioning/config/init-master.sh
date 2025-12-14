#!/bin/bash
# Script d'initialisation du noeud master Kubernetes
# Ce script doit etre execute uniquement sur le master

set -e

MASTER_IP="192.168.56.10"

echo "[Master] Initialisation du cluster Kubernetes..."
kubeadm init --apiserver-advertise-address="$MASTER_IP" --pod-network-cidr=10.244.0.0/16

echo "[Master] Configuration de kubectl pour l'utilisateur vagrant..."
mkdir -p /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

echo "[Master] Installation de Flannel"
sudo -u vagrant kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo "[Master] Extraction de la commande de jonction..."

# Extraire le token existant créé par kubeadm init
TOKEN=$(kubeadm token list | grep authentication | head -n1 | awk '{print $1}')
CA_CERT_HASH="sha256:$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')"

echo "kubeadm join 192.168.56.10:6443 --token $TOKEN --discovery-token-ca-cert-hash $CA_CERT_HASH" > /vagrant/join.sh
chmod +x /vagrant/join.sh

# Attendre que le fichier soit bien écrit et synchronisé
sleep 3
sync

echo "[Master] Initialisation terminee"
echo "[Master] Les workers peuvent maintenant rejoindre le cluster"
echo ""
echo "[Master] Commande de jonction generee:"
cat /vagrant/join.sh
echo ""

echo "Master initialized at $(date)" > /vagrant/.master-ready
sync

echo "[Master] Configuration du StorageClass par défaut (local-path)"
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml || true
kubectl annotate storageclass local-path storageclass.kubernetes.io/is-default-class=true --overwrite || true

echo "[Master] Création du secret d'accès au registre GHCR"
kubectl create secret docker-registry ghcr-cred \
	--docker-server=ghcr.io \
	--docker-username=uha-sae53 \
	--docker-password='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' \
	--namespace=default || true

echo "[Master] Attente que le ServiceAccount default soit créé..."
until kubectl get serviceaccount default -n default >/dev/null 2>&1; do
	echo "[Master] ServiceAccount default pas encore disponible, attente..."
	sleep 2
done

echo "[Master] Attachement du secret au ServiceAccount par défaut"
kubectl patch serviceaccount default \
	-p '{"imagePullSecrets":[{"name":"ghcr-cred"}]}' \
	--namespace=default

echo "[Master] Attente des workers en Ready avant déploiement des manifests..."
ATTEMPTS=0
while true; do
	READY_NODES=$(kubectl get nodes --no-headers | awk '$2=="Ready" {print $1}' | wc -l)
	if [ "$READY_NODES" -ge 3 ]; then
		echo "[Master] Tous les nœuds sont Ready ($READY_NODES)."
		break
	fi
	ATTEMPTS=$((ATTEMPTS+1))
	if [ $ATTEMPTS -gt 60 ]; then
		echo "[Master] Timeout d'attente des nœuds Ready, on continue quand même."
		break
	fi
	echo "[Master] Nœuds Ready: $READY_NODES/3, nouvelle vérification dans 5s..."
	sleep 5
done

echo "[Master] Application automatique des manifests convertis par Compose"
if [ -d "/vagrant/manifests" ]; then
	kubectl apply -f /vagrant/manifests/ --recursive 2>&1 | grep -v "unchanged" || true
	echo "[Master] Manifests appliqués."
else
	echo "[Master] Dossier /vagrant/manifests introuvable, skip."
fi

echo "[Master] Installation d'ArgoCD..."
if [ -f "/vagrant/config/install-argocd.sh" ]; then
	bash /vagrant/config/install-argocd.sh
else
	echo "[Master] Script install-argocd.sh introuvable, skip."
fi
