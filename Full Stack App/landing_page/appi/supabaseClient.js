const { createClient } = require('@supabase/supabase-js');

module.exports = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY   // full-access key (kept only on server)
);