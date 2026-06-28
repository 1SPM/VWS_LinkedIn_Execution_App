-- VWS / Divinity LinkedIn Execution App
-- Supabase schema for shared dashboard state

create table if not exists public.vws_dashboard_state (
  id text primary key,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by text
);

alter table public.vws_dashboard_state enable row level security;

-- Allow authenticated teammates to read the shared dashboard state
create policy "Authenticated users can read dashboard state"
on public.vws_dashboard_state
for select
to authenticated
using (true);

-- Allow authenticated teammates to insert the shared row
create policy "Authenticated users can insert dashboard state"
on public.vws_dashboard_state
for insert
to authenticated
with check (true);

-- Allow authenticated teammates to update the shared row
create policy "Authenticated users can update dashboard state"
on public.vws_dashboard_state
for update
to authenticated
using (true)
with check (true);

-- Optional: seed the shared row once after creating the table
insert into public.vws_dashboard_state (id, payload, updated_at, updated_by)
values (
  'primary',
  '{"targets":[],"groups":[],"scripts":[],"weekly":[],"notes":[]}'::jsonb,
  now(),
  'seed'
)
on conflict (id) do nothing;
