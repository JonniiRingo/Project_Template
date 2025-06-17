-- create table if it doesn't exist yet
create table if not exists public.traffic (
  id          uuid        primary key default gen_random_uuid(),
  project     text        not null,
  visits      int         default 1,
  last_visit  timestamptz default now()
);

-- row-level security stays ON
alter table public.traffic enable row level security;

-- allow anon insert (only project + visits)
create or replace policy traffic_anon_insert
  on public.traffic
  for insert
  to public
  with check ( true );