-- À exécuter dans Supabase → SQL Editor
-- Corrige : "new row violates row-level security policy for table 'etudiants'"
-- Cause : l’app utilise la clé publique (rôle anon) ; il faut une policy INSERT pour anon.

alter table public.etudiants enable row level security;

-- Nettoyage des anciennes policies (noms possibles selon vos scripts précédents)
drop policy if exists "read_etudiants_authenticated" on public.etudiants;
drop policy if exists "insert_etudiants_authenticated" on public.etudiants;
drop policy if exists "update_etudiants_authenticated" on public.etudiants;
drop policy if exists "delete_etudiants_authenticated" on public.etudiants;
drop policy if exists "read_etudiants_all" on public.etudiants;
drop policy if exists "insert_etudiants_anon" on public.etudiants;
drop policy if exists "insert_etudiants_anon_dev" on public.etudiants;

-- Lecture : étudiants + enseignant (clé anon) + comptes connectés
create policy "read_etudiants_all"
on public.etudiants
for select
to anon, authenticated
using (true);

-- Insertion depuis l’app admin sans login Supabase (clé anon uniquement)
create policy "insert_etudiants_anon"
on public.etudiants
for insert
to anon
with check (true);

-- Si vous connectez l’admin avec Supabase Auth (recommandé en prod)
create policy "insert_etudiants_authenticated"
on public.etudiants
for insert
to authenticated
with check (true);

-- Optionnel : mise à jour / suppression (à restreindre en production)
create policy "update_etudiants_authenticated"
on public.etudiants
for update
to authenticated
using (true)
with check (true);

create policy "delete_etudiants_authenticated"
on public.etudiants
for delete
to authenticated
using (true);
