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
rm -f /vagrant/join.sh /vagrant/.master-ready

# Extraire la commande join de la sortie de kubeadm init (déjà exécuté)
# Le token initial a une durée de vie de 24h par défaut
kubeadm token create --ttl 24h --print-join-command > /vagrant/join.sh
chmod +x /vagrant/join.sh

# Attendre que le fichier soit bien écrit et synchronisé
sleep 2
sync

echo "[Master] Initialisation terminee"
echo "[Master] Les workers peuvent maintenant rejoindre le cluster"
echo ""
echo "[Master] Commande de jonction generee:"
cat /vagrant/join.sh
echo ""
echo "Master initialized at $(date)" > /vagrant/.master-ready
sync
