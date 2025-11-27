#!/bin/bash
set -e

MASTER_IP="192.168.56.10"
HOSTNAME=$(hostname)

echo "[1] Configuration du système"
swapoff -a
sed -i '/swap/d' /etc/fstab

modprobe br_netfilter
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

echo "[2] Installation Docker"
apt-get update -qq
apt-get install -y apt-transport-https ca-certificates curl gnupg

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list

apt-get update -qq
apt-get install -y docker-ce docker-ce-cli containerd.io

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

echo "[3] Installation Kubernetes"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update -qq
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet

if [[ "$HOSTNAME" == "master" ]]; then

    echo "[4] Initialisation du Master Kubernetes"
    kubeadm init --apiserver-advertise-address="$MASTER_IP" --pod-network-cidr=10.244.0.0/16

    mkdir -p /home/vagrant/.kube
    cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    chown vagrant:vagrant /home/vagrant/.kube/config

    echo "[5] Installation de Flannel"
    sudo -u vagrant kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

    echo "[6] Génération du token pour workers"
    # Supprimer les anciens fichiers pour éviter les conflits
    rm -f /vagrant/join.sh /vagrant/.master-ready
    
    # Créer un nouveau token avec durée de vie de 24h (au lieu de 2h par défaut)
    kubeadm token create --ttl 24h --print-join-command > /vagrant/join.sh
    chmod +x /vagrant/join.sh
    
    # Créer un fichier flag pour indiquer que le master est complètement prêt
    echo "Master initialized at $(date)" > /vagrant/.master-ready
    echo "[Master] Prêt - les workers peuvent maintenant rejoindre le cluster"

elif [[ "$HOSTNAME" == slave-* ]]; then

    echo "[Worker] Attente de l'initialisation complète du master..."
    # Attendre que le master crée le fichier flag
    WAIT_COUNT=0
    while [ ! -f /vagrant/.master-ready ]; do
        echo "[Worker] Master pas encore prêt (attente ${WAIT_COUNT}s)..."
        sleep 10
        WAIT_COUNT=$((WAIT_COUNT + 10))
        if [ $WAIT_COUNT -gt 600 ]; then
            echo "[Worker] ERREUR: Timeout - le master n'est pas prêt après 10 minutes"
            exit 1
        fi
    done
    
    echo "[Worker] Master prêt détecté, attente du fichier join.sh..."
    while [ ! -f /vagrant/join.sh ]; do
        echo "[Worker] Fichier join.sh pas encore disponible..."
        sleep 5
    done
    
    # Attendre quelques secondes supplémentaires pour la propagation du token dans le cluster
    echo "[Worker] Attente de 15 secondes pour la propagation complète du token..."
    sleep 15
    
    echo "[Worker] Jonction au cluster Kubernetes..."
    bash /vagrant/join.sh
    
    if [ $? -eq 0 ]; then
        echo "[Worker] ✓ Jonction réussie au cluster!"
    else
        echo "[Worker] ✗ Échec de la jonction au cluster"
        exit 1
    fi
fi
