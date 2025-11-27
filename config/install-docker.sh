#!/bin/bash
# Script d'installation de Docker pour Kubernetes
# Ce script sera copie et execute sur chaque noeud

set -e

echo "[Docker] Installation des dependances..."
apt-get update -qq
apt-get install -y apt-transport-https ca-certificates curl gnupg

echo "[Docker] Configuration du repository Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list

echo "[Docker] Installation de Docker..."
apt-get update -qq
apt-get install -y docker-ce docker-ce-cli containerd.io

echo "[Docker] Configuration de containerd pour Kubernetes..."
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

echo "[Docker] Redemarrage de containerd..."
systemctl restart containerd
systemctl enable containerd

echo "[Docker] Installation terminee"
