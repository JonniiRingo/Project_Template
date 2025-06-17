# ─────────────── 0. GLOBAL PREREQUISITES (run once per machine) ───────────────
brew install node gh supabase/tap/supabase           # Node, GitHub CLI, Supabase CLI
npm  i  -g  vercel                                   # Vercel CLI (global)

# ─────────────── 1. START A FRESH PROJECT FOLDER ───────────────
mkdir my-portfolio && cd my-portfolio                # <-- change name if you want

# ─────────────── 2. DROP IN THE AUTOMATION SCRIPT ───────────────
cat <<'EOF' > react-setup.sh
#!/usr/bin/env bash
# --- derived from your old script, trimmed & fixed for Vite + Supabase ---
set -e

PROJECT_DIR="\$PWD"
REPO_NAME=\$(basename "\$PROJECT_DIR")

echo "🔹 cleaning node_modules"; rm -rf node_modules

# ─────────────── using inhouse cli dev tools ───────────────

npm run dev-bootstrap   # full OS tooling
npm run setup           # project scaffold

# Vite + React scaffold
npm create vite@latest . -- --template react
npm i                                                 # install starter deps

# Your stack in one shot
npm i @supabase/supabase-js react-router-dom framer-motion lucide-react
npm i -D tailwindcss postcss autoprefixer vite-plugin-svgr
npx tailwindcss init -p                              # tailwind + postcss config

# Supabase local scaffold
supabase init                                        # puts ./supabase/*
supabase start                                       # postgres on :54321

# Git ignore
cat > .gitignore <<'GIT'
node_modules
.env*
dist
.supabase
GIT

# GitHub repo (requires `gh auth login` once on this machine)
if ! gh repo view "$REPO_NAME" >/dev/null 2>&1; then
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
else
  git init && git remote add origin "https://github.com/YourUser/$REPO_NAME.git"
fi
git add . && git commit -m "Scaffold: Vite + React + Supabase"

# .env.local template
cat > .env.local <<'ENV'
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_ANON_KEY=anon
ENV

echo "✅  setup complete — next: run 'npm run dev' in another tab"
EOF

chmod +x react-setup.sh

# ─────────────── 3. EXECUTE THE SCRIPT ───────────────
./react-setup.sh                                     # takes ~1-2 min

# ─────────────── 4. ADD THE TRACKING HELPER ───────────────
mkdir -p src/utils
cat > src/utils/track.js <<'JS'
export async function track(project) {
  try {
    await fetch('/api/track', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ project })
    });
  } catch (_) { /* analytics failure ≠ fatal */ }
}
JS

# ─────────────── 5. SERVERLESS FUNCTION (Supabase insert) ───────────────
mkdir -p api
cat > api/track.js <<'JS'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.VITE_SUPABASE_URL,
  process.env.VITE_SERVICE_ROLE_SECRET            // service role ► insert without RLS block
)

export default async (req, res) => {
  try {
    const { project } = await req.json()
    await supabase.from('traffic').insert({ project_name: project, visits: 1 })
    return res.status(204).end()
  } catch (e) { return res.status(500).json({ error: e.message }) }
}
JS

# ─────────────── 6. LOCAL DEV LOOP ───────────────
# open two terminals:
#  A) supabase start        (if not already running)
#  B) npm run dev           (Vite on http://localhost:5173)

# ─────────────── 7. PUSH & DEPLOY ───────────────
git push -u origin main
vercel link                      # once
vercel env add VITE_SUPABASE_URL
vercel env add VITE_SUPABASE_ANON_KEY
vercel env add VITE_SERVICE_ROLE_SECRET
vercel --prod