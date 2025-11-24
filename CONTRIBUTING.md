# Guide de Contribution

Merci de votre intérêt pour contribuer à ce projet !

## Comment Contribuer

### 1. Signaler un Problème

Si vous rencontrez un bug ou avez une suggestion :

1. Vérifiez que le problème n'existe pas déjà dans les [Issues](https://github.com/uha-sae53/Vagrant/issues)
2. Créez une nouvelle issue avec :
   - Un titre descriptif
   - Les étapes pour reproduire le problème
   - Le comportement attendu vs actuel
   - Votre environnement (OS, Vagrant version, VirtualBox version)

### 2. Proposer des Modifications

1. Forkez le dépôt
2. Créez une branche pour votre fonctionnalité :
   ```bash
   git checkout -b feature/ma-nouvelle-fonctionnalite
   ```
3. Effectuez vos modifications
4. Testez vos changements :
   ```bash
   vagrant destroy -f
   vagrant up
   # Vérifiez que tout fonctionne
   ```
5. Committez avec un message descriptif :
   ```bash
   git commit -m "Add: Description de la modification"
   ```
6. Poussez vers votre fork :
   ```bash
   git push origin feature/ma-nouvelle-fonctionnalite
   ```
7. Créez une Pull Request

## Standards de Code

### Vagrantfile

- Utilisez 2 espaces pour l'indentation
- Commentez les configurations non-évidentes
- Testez avec `ruby -c Vagrantfile` avant de committer
- Gardez la structure cohérente avec le fichier existant

### Documentation

- Rédigez en français
- Utilisez le Markdown standard
- Incluez des exemples concrets
- Mettez à jour le README.md si nécessaire

## Tests

Avant de soumettre une Pull Request, assurez-vous que :

1. Le Vagrantfile est syntaxiquement correct :
   ```bash
   ruby -c Vagrantfile
   ```

2. Les VMs démarrent correctement :
   ```bash
   vagrant destroy -f
   vagrant up
   vagrant status
   ```

3. Les services fonctionnent :
   ```bash
   vagrant ssh web -c "sudo systemctl status nginx"
   vagrant ssh db -c "sudo systemctl status mysql"
   ```

4. La documentation est à jour et sans erreurs

## Types de Contributions Bienvenues

- 🐛 Corrections de bugs
- 📝 Amélioration de la documentation
- ✨ Nouvelles fonctionnalités
- 🎨 Améliorations de la configuration
- 🔧 Scripts d'automatisation
- 📊 Exemples d'utilisation

## Conventions de Commit

Utilisez des préfixes clairs :

- `Add:` Ajout de nouvelle fonctionnalité
- `Fix:` Correction de bug
- `Update:` Mise à jour de code existant
- `Doc:` Modifications de documentation
- `Refactor:` Refactorisation sans changement de fonctionnalité
- `Test:` Ajout ou modification de tests

Exemple :
```
Add: Support pour Ubuntu 22.04 LTS
Fix: Correction du provisioning MySQL
Doc: Mise à jour du guide d'installation
```

## Code de Conduite

- Soyez respectueux et professionnel
- Acceptez les critiques constructives
- Concentrez-vous sur ce qui est meilleur pour le projet
- Faites preuve d'empathie envers les autres contributeurs

## Questions ?

Si vous avez des questions, n'hésitez pas à :

- Ouvrir une [issue](https://github.com/uha-sae53/Vagrant/issues)
- Contacter les mainteneurs du projet

Merci de contribuer ! 🎉
