import { createClient, type SupabaseClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

let _supabase: SupabaseClient | null = null;

function getSupabaseClient(): SupabaseClient {
  if (!_supabase) {
    if (!supabaseUrl || !supabaseAnonKey) {
      console.warn(
        "Missing NEXT_PUBLIC_SUPABASE_URL or NEXT_PUBLIC_SUPABASE_ANON_KEY. Copy .env.local.example to .env.local.",
      );
    }
    _supabase = createClient(supabaseUrl ?? "", supabaseAnonKey ?? "", {
      auth: { persistSession: false },
    });
  }
  return _supabase;
}

// Lazily instantiate the client so importing this module during a server
// build (prerender) never calls createClient() and never throws when the
// public env vars are absent. The real client is created on first use
// (in the browser, where the NEXT_PUBLIC_* values are inlined).
export const supabase = new Proxy({} as SupabaseClient, {
  get: (_target, prop) => {
    const client = getSupabaseClient();
    const value = (client as unknown as Record<string | symbol, unknown>)[prop];
    return typeof value === "function" ? value.bind(client) : value;
  },
}) as SupabaseClient;
