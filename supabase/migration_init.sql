-- ============================================================
-- Migration : table de logs des calculs écotaxe
-- À exécuter dans : Supabase > SQL Editor
-- ============================================================

create table if not exists public.calculs_ecotaxe (
  id            bigserial primary key,
  created_at    timestamptz not null default now(),

  -- Données véhicule
  date_mec      text,          -- ex: "2024-10"
  energie       text,          -- ex: "hybride_rech_gt50"
  co2_brut      integer,       -- émissions CO2 saisies (g/km)
  co2_effectif  integer,       -- CO2 après abattement énergie (g/km)
  poids_kg      integer,       -- poids saisi (kg), null si non renseigné
  bareme        text,          -- "NEDC" ou "WLTP"
  annee_bareme  integer,       -- année du barème utilisé

  -- Résultats calcul
  mois_anciennete     integer,
  taux_abattement     integer,   -- en %
  malus_neuf          numeric(10,2),
  malus_apres_abatt   numeric(10,2),
  taxe_poids          numeric(10,2),
  total_ecotaxe       numeric(10,2),

  -- Carte grise
  dept_code       text,          -- ex: "67"
  dept_nom        text,          -- ex: "67 Bas-Rhin"
  cv_fiscaux      integer,
  taxe_regionale  numeric(10,2),
  total_cg        numeric(10,2)
);

-- Index pour les analyses
create index on public.calculs_ecotaxe (created_at desc);
create index on public.calculs_ecotaxe (energie);
create index on public.calculs_ecotaxe (dept_code);
create index on public.calculs_ecotaxe (annee_bareme);

-- RLS : autoriser uniquement les INSERT anonymes (lecture = admin uniquement)
alter table public.calculs_ecotaxe enable row level security;

create policy "insert_public"
  on public.calculs_ecotaxe
  for insert
  to anon
  with check (true);

-- Lecture réservée aux rôles authentifiés (dashboard admin)
create policy "select_authenticated"
  on public.calculs_ecotaxe
  for select
  to authenticated
  using (true);

-- ============================================================
-- Vue d'analyse rapide (optionnelle)
-- ============================================================
create or replace view public.stats_ecotaxe as
select
  annee_bareme,
  energie,
  count(*)                          as nb_calculs,
  round(avg(co2_brut))              as co2_moyen,
  round(avg(total_ecotaxe)::numeric, 2) as ecotaxe_moyenne,
  round(avg(total_cg)::numeric, 2)  as cg_moyenne,
  date_trunc('day', min(created_at)) as premier_calcul,
  date_trunc('day', max(created_at)) as dernier_calcul
from public.calculs_ecotaxe
where total_ecotaxe is not null
group by annee_bareme, energie
order by annee_bareme desc, nb_calculs desc;
