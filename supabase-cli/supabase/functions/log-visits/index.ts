// supabase/functions/log-visit/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (req) => {
  const { project_name } = await req.json();

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const res = await fetch(`${supabaseUrl}/rest/v1/project_traffic`, {
    method: "POST",
    headers: {
      apikey: supabaseKey,
      Authorization: `Bearer ${supabaseKey}`,
      "Content-Type": "application/json",
      Prefer: "resolution=merge-duplicates",
    },
    body: JSON.stringify({
      project_name,
      visit_count: 1,
      last_visit: new Date().toISOString(),
    }),
  });

  const result = await res.json();
  return new Response(JSON.stringify(result), {
    headers: { "Content-Type": "application/json" },
    status: res.status,
  });
});


// This logs a visit for project_name and merges duplicates.