-- supabase/migrations/20240605_init.sql

create table if not exists project_traffic (
  id uuid primary key default gen_random_uuid(),
  project_name text not null,
  visit_count int default 0,
  last_visit timestamp default now(),
  created_at timestamp default now()
);

create index if not exists idx_project_name on project_traffic (project_name);