-- =====================================================================
-- OBLIGATOIRE : exécuter ce script dans Supabase → SQL Editor → Run
-- Sans cette table, l’app affiche PGRST205 (table introuvable).
-- =====================================================================
-- Table : publications / actualités (fil type Facebook)

create extension if not exists pgcrypto;

create table if not exists public.publications_actualites (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('publication', 'news')),
  titre text not null check (char_length(trim(titre)) > 0),
  contenu text not null check (char_length(trim(contenu)) > 0),
  image_url text,
  created_at timestamptz not null default now()
);

create index if not exists publications_actualites_created_at_idx
  on public.publications_actualites (created_at desc);

alter table public.publications_actualites enable row level security;

drop policy if exists "read_publications_all" on public.publications_actualites;
drop policy if exists "insert_publications_auth" on public.publications_actualites;

-- Lecture pour l'app (clé anon + étudiants)
create policy "read_publications_all"
on public.publications_actualites
for select
to anon, authenticated
using (true);

-- Insertion : comptes authentifiés (recommandé en production)
create policy "insert_publications_auth"
on public.publications_actualites
for insert
to authenticated
with check (true);

-- Si l'admin utilise la même app sans connexion (clé anon uniquement), décommentez
-- la policy suivante OU connectez l'admin avec Supabase Auth.
drop policy if exists "insert_publications_anon_dev" on public.publications_actualites;
create policy "insert_publications_anon_dev"
on public.publications_actualites
for insert
to anon
with check (true);
