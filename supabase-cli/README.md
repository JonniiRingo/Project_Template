# Supabase + Edge Functions Bootstrap Guide

## Example Workflow

```bash
# 1. Login to Supabase
supabase login
# opens browser, asks for token auth

# 2. Create a new Supabase project
supabase projects create portfolio-db \
  --org-id YOUR_ORG_ID \
  --db-password "YOUR_PASSWORD" \
  --region us-east-1

# 3. Initialize Supabase directory structure
supabase init

# 4. Link local project to Supabase
supabase link --project-ref YOUR_PROJECT_REF

# Deploy linked project
cd supabase                  # now CWD == portfolio/supabase
supabase functions deploy log-visit

# 5. Push your schema
supabase db push
```

---

## Final Project Structure

```
portfolio/
├── supabase/
│   ├── config.toml
│   ├── .env
│   ├── supabase.env
│   ├── functions/
│   │   └── log-visit/
│   │       ├── index.ts
│   │       ├── deno.json
│   │       └── import_map.json
│   └── migrations/
│       └── 20240605_init.sql
├── .env
└── README.md
```

---

## Test Function Locally

```bash
supabase functions serve --no-verify-jwt
```

```bash
curl -X POST http://localhost:54321/functions/v1/log-visit \
  -H "Content-Type: application/json" \
  -d '{"project_name": "Portfolio"}'
```

---

## SQL Migration Example

**`supabase/migrations/20240605_init.sql`**:

```sql
create table if not exists project_traffic (
  id uuid primary key default gen_random_uuid(),
  project_name text not null,
  visit_count int default 0,
  last_visit timestamp default now(),
  created_at timestamp default now()
);

create index if not exists idx_project_name on project_traffic (project_name);
```

Run migration:
```bash
supabase db push
```

---

## .env File

```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

---

## supa-bootstrap Directory Structure

```
supa-bootstrap/
├── bin/
│   └── supa-bootstrap.js
├── templates/
│   ├── base/
│   │   ├── supabase.env
│   │   ├── .env
│   │   └── config.toml
│   ├── functions/
│   │   └── log-visit/
│   │       ├── index.ts
│   │       ├── deno.json
│   │       └── import_map.json
│   └── migrations/
│       └── 20240605_init.sql
├── .env
└── README.md
```