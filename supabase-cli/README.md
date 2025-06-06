 Example Workflow:

 supabase login
# opens browser, asks for token auth
supabase projects create portfolio-db \
  --org-id HASH \
  --db-password "PASSWORD" \
  --region us-east-1

supabase init
# creates supabase/ directory with config

supabase link --project-ref abcdefghijklmnop
# links CLI to your Supabase project

supabase db push
# pushes local schema.sql to your cloud db




# Project Structure After supabase init
.
├── supabase
│   ├── config.toml
│   ├── migrations/
│   └── functions/
├── supabase.env
└── .env         # Your project secrets here (ANON_KEY, URL)


# You can test locally with 
supabase functions serve --no-verify-jwt

# Then Post

curl -X POST http://localhost:54321/functions/v1/log-visit \
-H "Content-Type: application/json" \
-d '{"project_name": "Portfolio"}'




# -- supabase/migrations/20240605_init.sql

create table if not exists project_traffic (
  id uuid primary key default gen_random_uuid(),
  project_name text not null,
  visit_count int default 0,
  last_visit timestamp default now(),
  created_at timestamp default now()
);

create index if not exists idx_project_name on project_traffic (project_name);



This creates the analytics logging table and an index for lookup speed.

supabase db push


ad env to .env 
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key



# Directory structure:

supa-bootstrap/
├── bin/
│   └── supa-bootstrap.js
├── templates/
│   ├── base/
│   │   └── supabase.env
│   ├── functions/
│   │   └── log-visit.js
│   └── migrations/
├── .env
├── config.toml
├── supabase.env