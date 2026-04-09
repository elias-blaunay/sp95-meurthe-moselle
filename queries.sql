-- ============================================================
--  PROJET : Prix du SP95 en Meurthe-et-Moselle
--  Source  : Open data gouvernemental — prix-carburants.gouv.fr
--  Dataset : fr_carburant.fr_carburant (chargé dans BigQuery)
--  Auteur  : Elias BLAUNAY
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- ÉTAPE 1 : Explorer la table
-- ─────────────────────────────────────────────────────────────

-- 1.1 Afficher toute la table pour comprendre la structure
SELECT *
FROM fr_carburant.fr_carburant
LIMIT 100;


-- 1.2 Sélectionner uniquement les colonnes utiles pour le projet
SELECT
  adresse,
  ville,
  code_postal,
  code_departement,
  latitude,
  longitude,
  prix_SP95
FROM fr_carburant.fr_carburant
LIMIT 100;


-- ─────────────────────────────────────────────────────────────
-- ÉTAPE 2 : Comprendre les données SP95
-- ─────────────────────────────────────────────────────────────

-- 2.1 Trouver le prix minimum et maximum du SP95 sur toute la France
SELECT
  ROUND(MIN(prix_SP95), 2) AS prix_min,
  ROUND(MAX(prix_SP95), 2) AS prix_max,
  ROUND(AVG(prix_SP95), 2) AS prix_moyen
FROM fr_carburant.fr_carburant
WHERE prix_SP95 IS NOT NULL;


-- 2.2 Renommer les colonnes pour plus de lisibilité
SELECT
  adresse                          AS adresse,
  ville                            AS ville,
  ROUND(prix_SP95, 2)              AS prix_SP95_euros,
  code_departement                 AS departement
FROM fr_carburant.fr_carburant
WHERE prix_SP95 IS NOT NULL
LIMIT 50;


-- ─────────────────────────────────────────────────────────────
-- ÉTAPE 3 : Filtrer sur le département 54 (Meurthe-et-Moselle)
-- ─────────────────────────────────────────────────────────────

-- 3.1 Afficher toutes les stations du département 54
SELECT
  adresse,
  ville,
  code_postal,
  prix_SP95
FROM fr_carburant.fr_carburant
WHERE code_departement = "54";


-- 3.2 Compter le nombre de stations essence dans le département 54
SELECT
  COUNT(*) AS nb_stations_54
FROM fr_carburant.fr_carburant
WHERE code_departement = "54";


-- 3.3 Compter uniquement les stations avec du SP95 dans le département 54
SELECT
  COUNT(*) AS nb_stations_sp95_54
FROM fr_carburant.fr_carburant
WHERE code_departement = "54"
  AND prix_SP95 IS NOT NULL;


-- ─────────────────────────────────────────────────────────────
-- ÉTAPE 4 : Identifier la station la moins chère
-- ─────────────────────────────────────────────────────────────

-- 4.1 Classer toutes les stations du 54 par prix croissant
SELECT
  adresse,
  ville,
  ROUND(prix_SP95, 2) AS prix_SP95
FROM fr_carburant.fr_carburant
WHERE code_departement = "54"
  AND prix_SP95 IS NOT NULL
ORDER BY prix_SP95 ASC;


-- 4.2 Trouver uniquement la station la moins chère du département 54
SELECT
  adresse,
  ville,
  ROUND(prix_SP95, 2) AS prix_SP95
FROM fr_carburant.fr_carburant
WHERE code_departement = "54"
  AND prix_SP95 IS NOT NULL
ORDER BY prix_SP95 ASC
LIMIT 1;


-- ─────────────────────────────────────────────────────────────
-- ÉTAPE 5 : Requête finale — distance + prix pour le dashboard
-- ─────────────────────────────────────────────────────────────

-- Requête principale utilisée comme source dans Looker Studio.
-- Pour chaque station SP95 du département 54 :
--   - Calcule la distance en km depuis Nancy centre (ST_DISTANCE)
--   - Trie par prix croissant pour identifier les meilleures offres
--
-- ST_GEOGPOINT(longitude, latitude) : crée un point géographique
-- ST_DISTANCE(point_A, point_B)     : distance en mètres entre deux points
-- Division par 1000 → conversion en kilomètres

SELECT
  adresse,
  ville,
  CONCAT(adresse, " ", code_postal, " ", ville)   AS adresse_complete,
  ROUND(prix_SP95, 2)                              AS prix_SP95,
  ROUND(
    ST_DISTANCE(
      ST_GEOGPOINT(6.198348, 48.693502),            -- Point de référence : Nancy centre
      ST_GEOGPOINT(longitude, latitude)             -- Position de la station
    ) / 1000, 1
  )                                                AS distance_km
FROM fr_carburant.fr_carburant
WHERE code_departement = "54"
  AND prix_SP95 IS NOT NULL
ORDER BY prix_SP95;
