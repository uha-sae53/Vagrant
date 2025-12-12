#!/bin/bash
# Script d'installation de Kubernetes
# Ce script sera copié et exécuté sur chaque nœud

set -e

echo "[K8s] Configuration du repository Kubernetes..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor --batch --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg 2>/dev/null
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

echo "[K8s] Installation de kubelet, kubeadm et kubectl..."
apt-get update -qq
apt-get install -y kubelet kubeadm kubectl

echo "[K8s] Verrouillage des versions..."
apt-mark hold kubelet kubeadm kubectl

echo "[K8s] Activation de kubelet..."
systemctl enable kubelet


echo "[Systeme] Configuration du systèmes de PVC automatique"
# Activer le provisioner Local Path et le définir par défaut SI kubectl est disponible.
if command -v kubectl >/dev/null 2>&1; then
	# S'assurer que KUBECONFIG est défini (master)
	export KUBECONFIG=${KUBECONFIG:-/etc/kubernetes/admin.conf}
	kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml || true
	kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' || true
else
	echo "[Systeme] kubectl non disponible (node pas encore initialisé), saut de la config PVC."
fi

echo "[Systeme] Configuration de git et du registre..."
sudo apt install git -y
echo "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" | docker login ghcr.io -u uha-sae53 --password-stdin


echo "[K8s] Installation terminee"
