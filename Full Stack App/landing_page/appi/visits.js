// api/track.js
//
// • Works as an Express route **or** a Vercel/Netlify serverless function.
//   (Vercel will automatically treat any file under /api as a function.)
// • Expects JSON { project: 'some-id' } and writes one row to `traffic`.

import { createClient } from '@supabase/supabase-js';

// server-side keys 👉  DO NOT bundle into the client
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY   // full-access key
);

// --- Vercel style export ---
export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { project = 'portfolio' } = req.body ?? {};

    const { error } = await supabase
      .from('traffic')
      .insert({ project, visits: 1 });

    if (error) return res.status(400).json({ error });

    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
}

/* ===== IF you are running an Express server locally:
import express from 'express';
const router = express.Router();
router.post('/', handler);
export default router;
*/