# Vagrant
Répertoire des Vagrantfile pour l'infrastructure

## Objectif
Ce Vagrantfile permet de déployer automatiquement une infrastructure composée de 3 machines virtuelles pour le projet SAE e-commerce.

## Installation de Vagrant
Instructions pour installer Vagrant sur différentes plateformes : https://www.vagrantup.com/docs/installation

## Modules utilisés pour le déploiement de l'infrastructure

Installation du plugin vagrant-reload (permet de redémarrer une VM durant le provisioning) :

```bash
vagrant plugin install vagrant-reload
```

Installation du module pour utiliser Vagrant sur QEMU/KVM :

```bash
vagrant plugin install vagrant-libvirt
```

## Utilisation

Pour démarrer l'infrastructure :

```bash
vagrant up
```

Pour arrêter les machines virtuelles :

```bash
vagrant halt
```

Pour supprimer l'infrastructure :

```bash
vagrant destroy
```
