# VWS / Divinity LinkedIn Execution App

Static browser dashboard for managing LinkedIn lead mining, top targets, content scripts, weekly planning, and KPI review.

## What it is
- Interactive browser dashboard
- Local-first with optional Supabase shared storage
- Designed for Vercel static hosting

## Files
- `index.html` — main app
- `config.js` — Supabase configuration hook
- `supabase_schema.sql` — database schema + RLS policies
- `vercel.json` — static hosting config
- `package.json` — lightweight local run scripts

## Local run

```bash
python3 -m http.server 8001 --directory /Users/seanmckay/VWS_LinkedIn_Execution_App
```

Then open:

```text
http://localhost:8001/
```

## Supabase setup
1. Open the Supabase SQL editor.
2. Paste the contents of `supabase_schema.sql`.
3. Run the script.
4. Confirm the table `public.vws_dashboard_state` exists.
5. Confirm the `primary` row exists.

## Vercel deployment
1. Create or open the Vercel project for this app.
2. Point the project to this directory.
3. Deploy as a static site.
4. Keep `config.js` in the project for the Supabase URL and anon key.

## Team access
- Team members should sign in with magic-link email auth.
- The app reads and writes the shared row in Supabase.
- Local browser storage remains a fallback.

## Notes
- The dashboard is intentionally static-friendly.
- Shared state is stored in one JSON payload row for simplicity.
- If the team grows or the schema needs finer-grained collaboration, split into normalized tables later.

## Ownership model
- Clarence owns Marketing.
- marci-ir owns Investment Outreach.
- The dashboard UI and shared state should make both workstreams visible at a glance.
