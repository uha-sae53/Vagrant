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

echo "[Worker] Master pret detecte, attente du fichier join.sh..."
while [ ! -f /vagrant/join.sh ]; do
    echo "[Worker] Fichier join.sh pas encore disponible..."
    sleep 5
done

echo "[Worker] Attente de 15 secondes pour la propagation complete du token..."
sleep 15

echo "[Worker] Jonction au cluster Kubernetes..."
bash /vagrant/join.sh

if [ $? -eq 0 ]; then
    echo "[Worker] Jonction reussie au cluster"
else
    echo "[Worker] Echec de la jonction au cluster"
    exit 1
fi
