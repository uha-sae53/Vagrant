#!/bin/bash
# Script de jonction d'un worker au cluster Kubernetes
# Ce script doit etre execute uniquement sur les workers

set -e

echo "[Worker] Attente de l'initialisation complete du master..."
WAIT_COUNT=0
while [ ! -f /vagrant/.master-ready ]; do
    echo "[Worker] Master pas encore pret (attente ${WAIT_COUNT}s)..."
    sleep 10
    WAIT_COUNT=$((WAIT_COUNT + 10))
    if [ $WAIT_COUNT -gt 600 ]; then
        echo "[Worker] ERREUR: Timeout - le master n'est pas pret apres 10 minutes"
        exit 1
    fi
done

echo "[Worker] Master pret detecte, le fichier join.sh devrait etre disponible..."

if [ ! -s /vagrant/join.sh ]; then
    echo "[Worker] ERREUR: join.sh n'existe pas ou est vide!"
    exit 1
fi

echo "[Worker] Verification du contenu de join.sh:"
cat /vagrant/join.sh
echo ""

echo "[Worker] Jonction au cluster Kubernetes..."
bash /vagrant/join.sh

if [ $? -eq 0 ]; then
    echo "[Worker] Jonction reussie au cluster"
else
    echo "[Worker] Echec de la jonction au cluster"
    exit 1
fi
