# Configuration ELK Stack - Guide d'utilisation

## Vue d'ensemble

Cette configuration permet de centraliser et visualiser les logs de tous les conteneurs Docker via la stack ELK (Elasticsearch, Logstash, Kibana).

### Architecture

```
Conteneurs Docker → Filebeat → Elasticsearch → Kibana
```

- **Filebeat** : Collecte les logs des conteneurs Docker
- **Elasticsearch** : Stocke et indexe les logs
- **Kibana** : Interface web pour visualiser et analyser les logs

## Démarrage de la stack

```bash
cd /home/id00l/Dev/SAE-ecommerce/Vagrant/docker
docker-compose up -d
```

## Accès aux services

- **Kibana** : http://localhost:5601
- **Elasticsearch** : http://localhost:9200
- **API Clients** : http://localhost:8000

## Configuration Kibana

### 1. Créer le Data View

1. Accédez à Kibana : http://localhost:5601
2. Attendez que Kibana soit complètement démarré (peut prendre 1-2 minutes)
3. Allez dans **Menu ☰** → **Management** → **Stack Management** → **Data Views**
4. Cliquez sur **Create data view**
5. Configurez :
   - **Name** : `Docker Logs`
   - **Index pattern** : `docker-logs-*`
   - **Timestamp field** : `@timestamp`
6. Cliquez sur **Create data view**

### 2. Explorer les logs

1. Allez dans **Menu ☰** → **Analytics** → **Discover**
2. Sélectionnez le Data View **Docker Logs**
3. Vous verrez maintenant tous les logs de vos conteneurs

### 3. Filtres utiles

Dans la barre de recherche KQL (Kibana Query Language) :

```kql
# Logs de l'API clients uniquement
container.labels.service: "api_clients"

# Logs avec niveau ERROR
log_level: "ERROR" or log_level: "CRITICAL"

# Logs du dernier jour
@timestamp >= "now-1d"

# Recherche dans le message
message: *error* or message: *exception*
```

### 4. Créer des visualisations

#### Graphique des erreurs par service

1. Allez dans **Menu ☰** → **Analytics** → **Visualize Library**
2. Cliquez sur **Create visualization**
3. Sélectionnez **Lens**
4. Configurez :
   - **Données** : docker-logs-*
   - **Métrique** : Count
   - **Groupe par** : container.labels.service
   - **Filtres** : log_level: "ERROR" OR log_level: "CRITICAL"

#### Timeline des requêtes

1. Créez une nouvelle visualisation **Lens**
2. Type : Line chart
3. Axe Y : Count
4. Axe X : @timestamp (Date histogram)
5. Groupe : service_name

### 5. Créer un Dashboard

1. Allez dans **Menu ☰** → **Analytics** → **Dashboard**
2. Cliquez sur **Create dashboard**
3. Ajoutez vos visualisations créées précédemment
4. Sauvegardez le dashboard avec un nom : "Monitoring SAE E-commerce"

## Commandes utiles

### Vérifier que Filebeat envoie des logs

```bash
# Vérifier les logs de Filebeat
docker logs docker-filebeat-1

# Vérifier les index dans Elasticsearch
curl http://localhost:9200/_cat/indices?v

# Compter les documents dans l'index
curl http://localhost:9200/docker-logs-*/_count
```

### Vérifier la santé d'Elasticsearch

```bash
curl http://localhost:9200/_cluster/health?pretty
```

### Générer des logs de test

```bash
# Inscription d'un utilisateur (génère des logs)
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test_user",
    "email": "test@example.com",
    "password": "TestPass123!",
    "password_confirm": "TestPass123!",
    "role": "client"
  }'

# Vérifier que les logs apparaissent dans Kibana après quelques secondes
```

## Troubleshooting

### Les logs n'apparaissent pas dans Kibana

1. Vérifiez que Filebeat fonctionne :
```bash
docker logs docker-filebeat-1
```

2. Vérifiez qu'Elasticsearch reçoit des données :
```bash
curl http://localhost:9200/docker-logs-*/_search?size=1&pretty
```

3. Vérifiez la configuration du Data View dans Kibana

### Elasticsearch est lent ou plante

1. Augmentez la mémoire allouée dans `docker-compose.yml` :
```yaml
environment:
  - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
```

2. Redémarrez les services :
```bash
docker-compose restart elasticsearch
```

### Nettoyer les anciens logs

```bash
# Supprimer les index de plus de 7 jours
curl -X DELETE "http://localhost:9200/docker-logs-$(date -d '7 days ago' +%Y.%m.%d)"
```

## Champs disponibles dans les logs

| Champ | Description |
|-------|-------------|
| `@timestamp` | Date et heure du log |
| `message` | Message du log brut |
| `service_name` | Nom du conteneur Docker |
| `container.labels.service` | Label de service du conteneur |
| `container.labels.type` | Type de service (api, database) |
| `log_level` | Niveau de log (INFO, ERROR, etc.) |
| `environment` | Environnement (production) |
| `project` | Nom du projet (sae-ecommerce) |

## Bonnes pratiques

1. **Rotation des logs** : Les logs Docker sont configurés pour limiter la taille (10MB max par fichier, 3 fichiers max)
2. **Nettoyage régulier** : Supprimez les anciens index pour libérer de l'espace
3. **Alertes** : Configurez des alertes dans Kibana pour être notifié des erreurs critiques
4. **Dashboards** : Créez des dashboards pour monitorer l'activité de vos services

## Exemples de requêtes KQL avancées

```kql
# Tous les logs d'erreur des 24 dernières heures
@timestamp >= "now-24h" AND (log_level: "ERROR" OR log_level: "CRITICAL")

# Logs de l'API clients avec le mot "timeout"
container.labels.service: "api_clients" AND message: *timeout*

# Logs de la base de données
container.labels.type: "database"

# Logs contenant des codes HTTP 500
message: *500* OR message: *"Internal Server Error"*

# Comptage des logs par niveau
# (utilisez cette requête dans une visualisation de type "Pie chart")
# Groupe par : log_level.keyword
```

## Architecture de l'index Elasticsearch

```
docker-logs-YYYY.MM.DD
├── @timestamp
├── message (texte brut du log)
├── service_name (nom du conteneur)
├── container
│   ├── id
│   ├── name
│   ├── image
│   └── labels
│       ├── service
│       └── type
├── gunicorn (si parsé)
│   ├── timestamp
│   ├── process_id
│   ├── log_level
│   └── message
├── environment
└── project
```

## Ressources supplémentaires

- [Documentation Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/index.html)
- [Documentation Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Documentation Kibana](https://www.elastic.co/guide/en/kibana/current/index.html)
- [KQL Query Language](https://www.elastic.co/guide/en/kibana/current/kuery-query.html)
