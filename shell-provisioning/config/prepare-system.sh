#!/bin/bash
# Script de preparation du systeme pour Kubernetes
# Configuration reseau et desactivation du swap

set -e

echo "[Systeme] Desactivation du swap..."
swapoff -a
sed -i '/swap/d' /etc/fstab

echo "[Systeme] Configuration des modules kernel..."
modprobe br_netfilter

echo "[Systeme] Application de la configuration sysctl..."
cp /vagrant/config/sysctl-k8s.conf /etc/sysctl.d/k8s.conf
sysctl --system

echo "[Systeme] Configuration du systèmes de PVC automatique"
if command -v kubectl >/dev/null 2>&1; then
	export KUBECONFIG=${KUBECONFIG:-/etc/kubernetes/admin.conf}
	kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml || true
	kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' || true
else
	echo "[Systeme] kubectl non disponible, saut de la config PVC."
fi

echo "[Systeme] Configuration de git et du registre..."
sudo apt install -y git

echo "[Systeme] Preparation terminee"
