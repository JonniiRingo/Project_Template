#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Master spin-up script  |  Vite + React + Tailwind + Supabase + Vercel
#  © 2025  Adjust paths / names as you like.  Requires:
#    • Node ≥18, npm, git, gh-CLI, Homebrew (macOS) or equivalent
#    • Supabase CLI  (installed below if missing)
#    • Vercel CLI    (installed below if missing)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

################################################################################
# 0. INPUTS & HELPERS
################################################################################
if [[ $# -lt 1 ]]; then
  echo "USAGE:  $0 <project-directory> [supabase-project-ref]"
  exit 1
fi

PROJECT_DIR=$1
PROJECT_NAME=$(basename "$PROJECT_DIR")
SUPA_REF="${2:-}"     # may be empty
GIT_USER=$(git config --global user.name || echo "your-name")

prompt_yes_no () {      # $1 = question
  while true; do
    read -rp "$1 [y/n] " yn
    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
    esac
  done
}

run () { echo "▶ $*"; "$@"; }

################################################################################
# 1. CREATE DIR & CORE STARTER
################################################################################
run mkdir -p "$PROJECT_DIR" && cd "$PROJECT_DIR"
run npm init -y
run npm create vite@latest . -- --template react

################################################################################
# 2. INSTALL ALL DEPENDENCIES  (one shot)
################################################################################
run npm i                    # base Vite/React deps
run npm i @supabase/supabase-js react-router-dom framer-motion lucide-react
run npm i -D tailwindcss postcss autoprefixer vite-plugin-svgr

# Tailwind / PostCSS scaffolding
run npx tailwindcss init -p

################################################################################
# 3b. SUPA-BOOTSTRAP  (offline-aware)
################################################################################
LOCAL_TGZ=tools/supa-bootstrap.tgz   # put your .tgz here if you need it offline

if [[ -f "$LOCAL_TGZ" ]]; then
  echo "☛ Installing supa-bootstrap from local package $LOCAL_TGZ"
  npm i -g "$LOCAL_TGZ"
  supa-bootstrap || true
else
  echo "☛ Running remote supa-bootstrap (npx)"
  npx supa-bootstrap@latest || true
fi

################################################################################
# 4. INITIAL DB PULL / PUSH  (blank migrations ok)
################################################################################
supabase db pull   || true
supabase db push   || true   # no-op if nothing yet

################################################################################
# 5. LOCAL ENV SECRETS
################################################################################
cat <<EOF > .env.local
VITE_SUPABASE_URL=${SUPA_REF:+https://${SUPA_REF}.supabase.co}
VITE_SUPABASE_ANON_KEY=
# VITE_SERVICE_ROLE_SECRET=
EOF
echo "⚠️  Fill .env.local with your real keys."

################################################################################
# 6. NPM SCRIPTS PATCH  (adds supabase helpers)
################################################################################
npx json -I -f package.json \
  -e 'this.scripts ||= {}; 
      this.scripts.dev    ="vite";
      this.scripts.build  ="vite build";
      this.scripts.preview="vite preview";
      this.scripts["supabase:start"]="supabase start";
      this.scripts["supabase:studio"]="open http://localhost:54323";'

################################################################################
# 7. BASE CODE/UTILS BOILER-PLATE
################################################################################
mkdir -p src/utils
cat <<'JS' > src/utils/track.js
// src/utils/track.js  → client-side fire-and-forget hit
export async function track(project) {
  try {
    await fetch('/api/track', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ project })
    });
  } catch (_) { /* analytics failure must not break UI */ }
}
JS

mkdir -p api
cat <<'JS' > api/track.js
// api/track.js  → runs in Vercel Serverless / Supabase Edge
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.VITE_SUPABASE_URL,
  process.env.VITE_SERVICE_ROLE_SECRET   // server-side key
);

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end();

  const { project='' } = req.body ?? {};
  const { error } = await supabase
    .from('traffic')
    .insert({ project_name: project, visits: 1 });

  if (error) return res.status(500).json({ error });
  res.status(204).end();   // no content
}
JS

################################################################################
# 8. GIT BOOTSTRAP
################################################################################
if [[ ! -d .git ]]; then run git init; fi
run git add .
run git commit -m "Scaffold: Vite + React + Supabase stack"
run git branch -M main

if prompt_yes_no "↪  Push to GitHub now?"; then
  run gh repo create "$PROJECT_NAME" --public --source=. --remote=origin --push || \
    run git remote add origin "https://github.com/${GIT_USER}/${PROJECT_NAME}.git"
  run git push -u origin main || true
fi

################################################################################
# 9. VERCEL SETUP
################################################################################
if ! command -v vercel &>/dev/null; then
  run npm i -g vercel
fi

if prompt_yes_no "↪  Link + deploy to Vercel now?"; then
  vercel link --yes
  vercel env add VITE_SUPABASE_URL
  vercel env add VITE_SUPABASE_ANON_KEY
  # vercel env add VITE_SERVICE_ROLE_SECRET   # if used
  vercel env pull --yes
  vercel --prod
fi

################################################################################
# 10. FINISH
################################################################################
echo ""
echo "✅  Project '${PROJECT_NAME}' ready."
echo "   • Local dev DB  : npm run supabase:start"
echo "   • Vite dev server: npm run dev"
echo "   • Happy coding!"