# Boutiq Web (Next.js)

Web admin + POS front end for Boutiq, sharing the same Supabase backend as the
Flutter mobile app. Built with Next.js (App Router), TypeScript, and Tailwind CSS.

## Setup

```bash
cp .env.local.example .env.local   # then fill in your Supabase values
npm install
npm run dev                        # http://localhost:3000
```

Environment variables:

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`

These match the values used by the Flutter app (Supabase project anon key).

## Auth

Login is PIN-based, matching the `users` table (`pin` + `role`). The session is
stored in `localStorage`. RLS is currently disabled on Supabase, so the anon key
has full access (same as the Flutter app). Enable RLS + per-store policies before
production.

## Structure

- `app/login` — PIN login
- `app/(app)` — authenticated shell (sidebar + logout) with:
  - `dashboard` — KPIs (Sales Today, Orders Today, Low Stock) + 7-day sales chart
  - `pos`, `products`, `orders`, `clients`, `staff`, `settings` — coming next

## Deploy (Vercel)

In the Vercel dashboard, set the project **Root Directory** to `boutiq-web`
(so Vercel auto-detects Next.js), add the two env vars above, and deploy.
