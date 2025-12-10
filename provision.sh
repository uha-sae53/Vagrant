#!/bin/bash
set -e

HOSTNAME=$(hostname)
CONFIG_DIR="/vagrant/config"

echo "=========================================="
echo "  Provisioning de $HOSTNAME"
echo "=========================================="

if [[ "$HOSTNAME" == "master" ]]; then
    echo "[Cleanup] Suppression des anciens fichiers de coordination..."
    rm -f /vagrant/join.sh /vagrant/.master-ready
fi

chmod +x $CONFIG_DIR/*.sh

echo ""
echo "[1] Préparation du système"
bash $CONFIG_DIR/prepare-system.sh

echo ""
echo "[2] Installation de Docker"
bash $CONFIG_DIR/install-docker.sh

echo ""
echo "[3] Installation de Kubernetes"
bash $CONFIG_DIR/install-k8s.sh

if [[ "$HOSTNAME" == "master" ]]; then
    echo ""
    echo "[4] Initialisation du nœud Master"
    bash $CONFIG_DIR/init-master.sh

elif [[ "$HOSTNAME" == slave-* ]]; then
    echo ""
    echo "[4] Jonction au cluster (Worker)"
    bash $CONFIG_DIR/join-worker.sh
fi

echo ""
echo "[5] Installation du Dashboard Kubernetes (Master only)"
if [[ "$HOSTNAME" == "master" ]]; then
    bash $CONFIG_DIR/install-dashboard.sh
fi

echo ""

echo "=========================================="
