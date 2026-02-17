# Calculette Écotaxe & Carte Grise

Simulateur de malus écologique (CO₂ + poids) et de coût total de carte grise.  
Barèmes NEDC/WLTP 2015–2026 · Loi de finances 2025 · 101 départements.

---

## Structure du projet

```
├── app/
│   ├── layout.js              # Layout racine Next.js
│   ├── globals.css
│   ├── page.js                # Redirige vers /calculette
│   └── calculette/
│       └── page.js            # Page /calculette
├── components/
│   └── Calculette.jsx         # Composant principal (client-side)
├── lib/
│   └── supabase.js            # Client Supabase
├── supabase/
│   └── migration_init.sql     # Script SQL à exécuter dans Supabase
├── .env.local.example         # Template variables d'environnement
└── .gitignore
```

---

## Installation locale

```bash
# 1. Installer les dépendances
npm install

# 2. Copier le fichier d'environnement
cp .env.local.example .env.local

# 3. Remplir .env.local avec tes clés Supabase (voir ci-dessous)

# 4. Lancer le serveur de développement
npm run dev
# → http://localhost:3000/calculette
```

---

## Configuration Supabase

### 1. Créer le projet sur supabase.com

1. Va sur [supabase.com](https://supabase.com) → **New project**
2. Choisis un nom et une région (ex : `eu-west-3` Paris)
3. Note le **mot de passe de base de données** (tu en auras besoin pour les backups)

### 2. Créer la table de logs

1. Dans le dashboard Supabase → **SQL Editor**
2. Colle et exécute le contenu de `supabase/migration_init.sql`

Ce script crée :
- La table `calculs_ecotaxe` avec tous les champs nécessaires
- Les politiques RLS (Row Level Security) : INSERT public, SELECT réservé aux utilisateurs authentifiés
- Une vue `stats_ecotaxe` pour les analyses rapides

### 3. Récupérer les clés API

Dans Supabase → **Project Settings** → **API** :

```env
NEXT_PUBLIC_SUPABASE_URL=https://XXXXXXXXXXXX.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Colle ces valeurs dans ton fichier `.env.local`.

---

## Déploiement sur Vercel

### 1. Pousser sur GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/TON_USER/calculette-ecotaxe.git
git push -u origin main
```

### 2. Importer sur Vercel

1. Va sur [vercel.com](https://vercel.com) → **Add New Project**
2. Importe ton dépôt GitHub
3. Framework : **Next.js** (détecté automatiquement)
4. Ajoute les variables d'environnement :
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
5. Clique sur **Deploy**

Vercel redéploie automatiquement à chaque `git push` sur `main`.

---

## Fonctionnement du logging Supabase

Chaque calcul complet (date MEC + CO₂ renseignés) est loggé automatiquement dans Supabase après un délai de **2 secondes** d'inactivité (debounce). Cela évite de logger chaque frappe de touche.

Les données loggées incluent :
- Date de mise en circulation, énergie, CO₂, poids
- Barème utilisé (NEDC/WLTP), année
- Tous les montants calculés (malus neuf, abattement, taxe poids, total)
- Département, chevaux fiscaux, total carte grise

Pour consulter les logs : Supabase → **Table Editor** → `calculs_ecotaxe`  
Pour les stats : Supabase → **SQL Editor** → `select * from stats_ecotaxe;`

---

## Sources réglementaires

- Art. L.421-67 CIBS — Exonération électrique/hydrogène
- Art. L.421-68 CIBS — Abattement E85 (40%)
- Art. L.421-77 CIBS — Abattements hybride sur la masse
- Loi n° 2025-127 du 14 février 2025 de finances pour 2025
- BOFiP BOI-AIS-MOB-10-20-40
