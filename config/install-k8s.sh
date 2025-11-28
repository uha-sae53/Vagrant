#!/bin/bash
# Script d'installation de Kubernetes
# Ce script sera copié et exécuté sur chaque nœud

set -e

echo "[K8s] Configuration du repository Kubernetes..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

echo "[K8s] Installation de kubelet, kubeadm et kubectl..."
apt-get update -qq
apt-get install -y kubelet kubeadm kubectl

echo "[K8s] Verrouillage des versions..."
apt-mark hold kubelet kubeadm kubectl

echo "[K8s] Activation de kubelet..."
systemctl enable kubelet

echo "[K8s] Installation terminee"
