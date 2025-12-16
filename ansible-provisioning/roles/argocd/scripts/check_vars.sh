#!/bin/bash
set -e

if [ -z "roles/argocd/vars/main.yml" ]; then
  echo "Error: Il manque le fichier de variables roles/argocd/vars/main.yml"
  echo "Veuillez le créer avant de continuer."
  echo "Vous pouvez copier le fichier d'exemple roles/argocd/vars/main.temp et remplacer les valeurs nécessaires."
  exit 1
fi