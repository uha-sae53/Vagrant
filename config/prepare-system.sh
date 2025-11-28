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

echo "[Systeme] Preparation terminee"

