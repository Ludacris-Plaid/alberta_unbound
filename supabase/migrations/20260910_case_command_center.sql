-- Case Command Center: owner-scoped case file system
-- Tables: case_contacts, case_timeline (replaces journal_entries), case_evidence, case_deadlines

create table if not exists public.case_contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  role text default '',
  office text default '',
  phone text default '',
  email text default '',
  notes text default '',
  created_at timestamptz not null default now()
);

create table if not exists public.case_timeline (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  entry_date date not null default current_date,
  entry_time text default '',
  channel text default 'phone',
  office text default '',
  contact_id uuid references public.case_contacts(id) on delete set null,
  contact_name text default '',
  reference_no text default '',
  summary text not null default '',
  promise text default '',
  outcome text default 'waiting',
  needs_follow_up boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.case_evidence (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  evidence_type text default 'letter',
  source text default '',
  evidence_date date,
  description text default '',
  storage_location text default '',
  tags text default '',
  created_at timestamptz not null default now()
);

create table if not exists public.case_deadlines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  due_date date not null,
  title text not null,
  category text default 'other',
  done boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists case_timeline_user_date on public.case_timeline (user_id, entry_date desc);
create index if not exists case_deadlines_user_due on public.case_deadlines (user_id, due_date);

alter table public.case_contacts enable row level security;
alter table public.case_timeline enable row level security;
alter table public.case_evidence enable row level security;
alter table public.case_deadlines enable row level security;

drop policy if exists "Owners manage case contacts" on public.case_contacts;
create policy "Owners manage case contacts" on public.case_contacts for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Owners manage case timeline" on public.case_timeline;
create policy "Owners manage case timeline" on public.case_timeline for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Owners manage case evidence" on public.case_evidence;
create policy "Owners manage case evidence" on public.case_evidence for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Owners manage case deadlines" on public.case_deadlines;
create policy "Owners manage case deadlines" on public.case_deadlines for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Migrate existing journal entries into case_timeline (once)
insert into public.case_timeline (id, user_id, entry_date, office, summary, promise, outcome, created_at)
select j.id, j.user_id, j.entry_date, j.program, coalesce(j.notes, ''), coalesce(j.outcome, ''),
       case when j.outcome ilike '%due%' or j.outcome ilike '%waiting%' then 'waiting' else 'waiting' end,
       j.created_at
from public.journal_entries j
where not exists (select 1 from public.case_timeline t where t.id = j.id);

-- Roadmap state stays local-only by design (ten public template steps per user,
-- tracked client-side); drop the server copies now that the desk owns case data.
drop table if exists public.user_roadmap_items cascade;
drop table if exists public.journal_entries cascade;
