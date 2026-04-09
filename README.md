# ⛽ Prix du SP95 en Meurthe-et-Moselle

**Stack :** BigQuery · SQL · Looker Studio  
**Données :** Open data gouvernemental — [Prix des carburants en France](https://www.prix-carburants.gouv.fr/rubrique/opendata/)  
**Département :** 54 — Meurthe-et-Moselle  

---

## 🎯 Problématique

> **Quelle est la station essence la moins chère autour de chez moi ?**

Avec la hausse des prix des carburants, identifier rapidement la station la moins chère à proximité représente une économie réelle sur le budget mensuel. Ce projet répond à cette question avec des données officielles, fraîches et géolocalisées.

---

## 📊 Dashboard interactif

https://lookerstudio.google.com/s/gshL7xUeyWw

Le dashboard permet de :
- Visualiser les **30 stations SP95** du département 54 sur une carte géolocalisée, colorée selon le prix (vert = moins cher, rouge = plus cher)
- Consulter la **répartition des prix** sur un graphique en barres
- Filtrer la **table des stations** par prix SP95 et distance depuis un point de référence
- Identifier **en un coup d'œil** la station la plus économique à proximité

![Dashboard SP95](dashboard.png)

---

## 🗂️ Méthodologie

### Étape 1 — Collecte des données
Source : [prix-carburants.gouv.fr](https://www.prix-carburants.gouv.fr/rubrique/opendata/)  
Téléchargement du fichier CSV quotidien mis à disposition par le gouvernement français.

### Étape 2 — Nettoyage des données
Import du CSV dans Google Sheets pour :
- Vérifier les types de colonnes (prix, coordonnées GPS, codes postaux)
- Supprimer les lignes sans prix SP95 renseigné
- Uniformiser les formats d'adresse

### Étape 3 — Chargement dans BigQuery
Création du dataset `fr_carburant` et de la table `fr_carburant` dans Google BigQuery.  
Le fichier CSV nettoyé est importé directement via l'interface BigQuery.

### Étape 4 — Analyse SQL
Requêtes progressives pour explorer les données et construire la logique du dashboard.  
→ Voir le fichier [`sql/queries.sql`](queries.sql)

### Étape 5 — Création du dashboard
Connexion de Looker Studio à la requête SQL finale comme source de données.  
Construction des 4 métriques, ajout des filtres interactifs et de la carte géolocalisée.

---

## 📐 Les 4 métriques du dashboard

| Métrique | Description |
|----------|-------------|
| **Nombre de stations** | Total de stations SP95 dans le département 54 |
| **Répartition des prix** | Histogramme de distribution des prix SP95 |
| **Tableau des stations** | Adresse, ville, prix SP95, distance en km — filtrable |
| **Carte des stations** | Carte géolocalisée avec code couleur prix |

---

## 💾 Requête SQL principale

```sql
SELECT
  adresse,
  ville,
  CONCAT(adresse, " ", code_postal, " ", ville) AS adresse_complete,
  ROUND(prix_SP95, 2) AS prix_SP95,
  ROUND(
    ST_DISTANCE(
      ST_GEOGPOINT(6.198348, 48.693502),   -- Point de référence : Nancy centre
      ST_GEOGPOINT(longitude, latitude)
    ) / 1000, 1
  ) AS distance_km
FROM fr_carburant.fr_carburant
WHERE code_departement = "54"
  AND prix_SP95 IS NOT NULL
ORDER BY prix_SP95
```

Cette requête utilise les fonctions géospatiales de BigQuery (`ST_GEOGPOINT`, `ST_DISTANCE`) pour calculer la distance en kilomètres entre chaque station et un point de référence (ici, Nancy centre), puis trie les résultats par prix croissant.

---

## 🛠️ Technologies utilisées

| Outil | Usage |
|-------|-------|
| **Google BigQuery** | Stockage et requêtage des données |
| **SQL** | Analyse, filtrage, calcul de distances géospatiales |
| **Looker Studio** | Visualisation, dashboard interactif |
| **Google Sheets** | Nettoyage initial des données |

---

## 📁 Structure du projet

```
sp95-meurthe-moselle/
├── README.md              ← Ce fichier
├── sql/
│   └── queries.sql        ← Toutes les requêtes SQL commentées
└── screenshots/
    ├── dashboard-sketch.png
    └── dashboard-final.png  ← À ajouter quand disponible
```

---

## 👤 Auteur

**Elias BLAUNAY**  
En cours de spécialisation Business Data Analyst (RNCP Niv. 7 — Ecole des Mines de Paris)  
📍 Nancy, Meurthe-et-Moselle  
🔗 [Portfolio](https://elias-blaunay.github.io) · [LinkedIn](https://linkedin.com/in/elias-blaunay)
