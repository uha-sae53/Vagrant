# Guide de Contribution

Merci de votre intérêt pour contribuer à ce projet Vagrant !

## 🤝 Comment contribuer

### Signaler un problème

Si vous rencontrez un problème :

1. Vérifiez que le problème n'a pas déjà été signalé dans les Issues
2. Créez une nouvelle Issue avec :
   - Une description claire du problème
   - Les étapes pour reproduire
   - Votre environnement (OS, version Vagrant, version VirtualBox)
   - Les logs d'erreur si applicable

### Proposer des améliorations

Pour proposer une amélioration :

1. Ouvrez une Issue pour discuter de votre proposition
2. Attendez les retours avant de commencer le développement
3. Créez une Pull Request avec vos modifications

### Soumettre une Pull Request

1. Fork le repository
2. Créez une branche pour votre fonctionnalité : `git checkout -b feature/ma-fonctionnalite`
3. Faites vos modifications
4. Testez vos changements localement : `vagrant destroy && vagrant up`
5. Committez vos changements : `git commit -m "Description claire"`
6. Poussez vers votre fork : `git push origin feature/ma-fonctionnalite`
7. Ouvrez une Pull Request

## ✅ Checklist avant de soumettre

- [ ] Le code est testé et fonctionne
- [ ] La documentation est mise à jour
- [ ] Le Vagrantfile respecte les conventions Ruby
- [ ] Les commentaires sont en français
- [ ] Les messages de commit sont clairs et descriptifs

## 📝 Conventions de code

### Vagrantfile

- Utilisez 2 espaces pour l'indentation
- Ajoutez des commentaires pour les sections importantes
- Utilisez des noms de variables explicites
- Gardez les provisioning scripts simples et lisibles

### Documentation

- Écrivez en français
- Utilisez des exemples concrets
- Incluez des captures d'écran si pertinent
- Maintenez la structure existante

## 🧪 Tests

Avant de soumettre une PR, testez :

```bash
# Test complet
vagrant destroy -f
vagrant up

# Test de chaque VM individuellement
vagrant up web
vagrant ssh web -c "curl localhost"

vagrant up db
vagrant ssh db -c "mysql -u root -pvagrant -e 'SELECT VERSION();'"

vagrant up app
vagrant ssh app -c "node --version"
```

## 🛠️ Améliorations souhaitées

Voici quelques idées d'amélioration :

- [ ] Ajouter un load balancer (nginx)
- [ ] Configurer SSL/TLS
- [ ] Ajouter un système de monitoring
- [ ] Créer des scripts de backup
- [ ] Ajouter des tests automatisés
- [ ] Améliorer la sécurité réseau
- [ ] Documenter des cas d'usage avancés

## 📞 Contact

Pour toute question, n'hésitez pas à :
- Ouvrir une Issue
- Contacter les mainteneurs du projet

## 📜 Code de conduite

Ce projet suit un code de conduite simple :
- Soyez respectueux
- Soyez constructif
- Aidez les autres

Merci pour votre contribution ! 🎉
