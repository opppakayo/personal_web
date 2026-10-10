-- Paste this whole file into Supabase -> SQL Editor -> Run.
-- Replace oppakayo141@gmail.com (appears 3 times) with the email you log in with.
-- Safe to run more than once.

create table if not exists public.vault (
  id int primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.vault enable row level security;

drop policy if exists "public read" on public.vault;
drop policy if exists "owner insert" on public.vault;
drop policy if exists "owner update" on public.vault;

-- everyone (visitors) can read
create policy "public read" on public.vault
  for select using (true);

-- only the owner can create / change
create policy "owner insert" on public.vault
  for insert to authenticated
  with check (lower(auth.jwt() ->> 'email') = lower('oppakayo141@gmail.com'));

create policy "owner update" on public.vault
  for update to authenticated
  using (lower(auth.jwt() ->> 'email') = lower('oppakayo141@gmail.com'))
  with check (lower(auth.jwt() ->> 'email') = lower('oppakayo141@gmail.com'));

-- make sure the API sees the new table right away
grant usage on schema public to anon, authenticated;
grant select on public.vault to anon, authenticated;
grant insert, update on public.vault to authenticated;
notify pgrst, 'reload schema';
