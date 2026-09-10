-- Alberta Unbound workspace and community governance migration
-- Apply with: supabase db push
-- Safe to re-run. This migration does not change The Vault tables or payment policies.

alter table public.profiles add column if not exists region text default '';
alter table public.profiles add column if not exists interests text default '';
alter table public.profiles add column if not exists is_admin boolean default false;

-- Protect server-controlled profile flags and avoid recursive profile RLS policies.
create or replace function public.current_user_is_admin()
returns boolean
language sql
stable
security definer
set search_path = public, pg_catalog
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and is_admin = true
  );
$$;

create or replace function public.profile_flag_value(target_id uuid, flag_name text)
returns boolean
language plpgsql
stable
security definer
set search_path = public, pg_catalog
as $$
declare
  result boolean;
begin
  if auth.uid() is null or auth.uid() <> target_id then
    raise exception 'A user may only inspect their own profile flags';
  elsif flag_name = 'is_member' then
    select p.is_member into result from public.profiles p where p.id = target_id;
  elsif flag_name = 'is_admin' then
    select p.is_admin into result from public.profiles p where p.id = target_id;
  else
    raise exception 'Unsupported profile flag';
  end if;
  return coalesce(result, false);
end;
$$;

revoke all on function public.current_user_is_admin() from public;
grant execute on function public.current_user_is_admin() to anon, authenticated;
revoke all on function public.profile_flag_value(uuid, text) from public;
grant execute on function public.profile_flag_value(uuid, text) to authenticated;

update public.profiles
set is_admin = true
where lower(username) = 'dysthemix';

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id)
  with check (
    auth.uid() = id
    and is_member = public.profile_flag_value(auth.uid(), 'is_member')
    and is_admin = public.profile_flag_value(auth.uid(), 'is_admin')
  );

create table if not exists public.manifesto_sections (
  id uuid primary key default uuid_generate_v4(),
  slug text unique not null,
  title text not null,
  body text not null default '',
  published boolean not null default true,
  updated_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.resources (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  category text not null,
  kind text not null default 'community',
  description text not null default '',
  phone text default '',
  url text not null,
  last_reviewed date,
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.roadmap_templates (
  id text primary key,
  title text not null,
  detail text not null default '',
  source_url text,
  sort_order integer not null default 0,
  is_published boolean not null default true
);

create table if not exists public.user_roadmap_items (
  user_id uuid references public.profiles(id) on delete cascade not null,
  item_id text references public.roadmap_templates(id) on delete cascade not null,
  completed boolean not null default false,
  completed_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (user_id, item_id)
);

create table if not exists public.journal_entries (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  entry_date date not null,
  program text not null,
  outcome text not null default '',
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.shared_case_summaries (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.profiles(id) on delete cascade not null,
  title text not null,
  summary text not null,
  consented_at timestamptz not null default now(),
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.campaigns (
  id uuid primary key default uuid_generate_v4(),
  slug text unique not null,
  title text not null,
  demand text not null default '',
  target text not null default '',
  evidence text not null default '',
  accessibility_plan text not null default '',
  status text not null default 'draft',
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.campaign_members (
  campaign_id uuid references public.campaigns(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  role text not null default 'participant',
  created_at timestamptz not null default now(),
  primary key (campaign_id, user_id)
);

create table if not exists public.reports (
  id uuid primary key default uuid_generate_v4(),
  reporter_id uuid references public.profiles(id) on delete set null,
  thread_id bigint references public.threads(id) on delete cascade,
  reply_id bigint references public.replies(id) on delete cascade,
  reason text not null,
  details text not null default '',
  status text not null default 'open',
  created_at timestamptz not null default now()
);

create table if not exists public.moderation_actions (
  id uuid primary key default uuid_generate_v4(),
  report_id uuid references public.reports(id) on delete cascade not null,
  moderator_id uuid references public.profiles(id) on delete set null not null,
  action text not null,
  note text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.content_revisions (
  id uuid primary key default uuid_generate_v4(),
  content_type text not null,
  content_id text not null,
  editor_id uuid references public.profiles(id) on delete set null,
  revision jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.manifesto_sections enable row level security;
alter table public.resources enable row level security;
alter table public.roadmap_templates enable row level security;
alter table public.user_roadmap_items enable row level security;
alter table public.journal_entries enable row level security;
alter table public.shared_case_summaries enable row level security;
alter table public.campaigns enable row level security;
alter table public.campaign_members enable row level security;
alter table public.reports enable row level security;
alter table public.moderation_actions enable row level security;
alter table public.content_revisions enable row level security;

-- Do not expose private profile fields such as email to anonymous users.
drop policy if exists "Public profiles are viewable by everyone" on public.profiles;
drop policy if exists "Users can view own profile" on public.profiles;
create policy "Users can view own profile" on public.profiles for select using (auth.uid() = id or public.current_user_is_admin());

-- Public reading; only flagged admins can edit editorial content.
drop policy if exists "Public can read published manifesto" on public.manifesto_sections;
create policy "Public can read published manifesto" on public.manifesto_sections for select using (published = true);
drop policy if exists "Admins manage manifesto" on public.manifesto_sections;
create policy "Admins manage manifesto" on public.manifesto_sections for all using (public.current_user_is_admin()) with check (public.current_user_is_admin());

drop policy if exists "Public can read resources" on public.resources;
create policy "Public can read resources" on public.resources for select using (is_published = true);
drop policy if exists "Admins manage resources" on public.resources;
create policy "Admins manage resources" on public.resources for all using (public.current_user_is_admin()) with check (public.current_user_is_admin());

drop policy if exists "Public can read roadmap templates" on public.roadmap_templates;
create policy "Public can read roadmap templates" on public.roadmap_templates for select using (is_published = true);
drop policy if exists "Admins manage roadmap templates" on public.roadmap_templates;
create policy "Admins manage roadmap templates" on public.roadmap_templates for all using (public.current_user_is_admin()) with check (public.current_user_is_admin());

-- Private owner-only workspace data.
drop policy if exists "Owners manage roadmap items" on public.user_roadmap_items;
create policy "Owners manage roadmap items" on public.user_roadmap_items for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Owners manage journal entries" on public.journal_entries;
create policy "Owners manage journal entries" on public.journal_entries for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Owners manage shared summaries" on public.shared_case_summaries;
create policy "Owners manage shared summaries" on public.shared_case_summaries for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Public reads published summaries" on public.shared_case_summaries;
create policy "Public reads published summaries" on public.shared_case_summaries for select using (is_published = true);

-- Safe public profile projection for future directory features; private columns stay off the view.
create or replace view public.public_profiles as
  select id, username, bio, avatar, region, interests, posts_count, created_at
  from public.profiles;
grant select on public.public_profiles to anon, authenticated;

-- Campaign bodies are public; membership is private to the member or admins.
drop policy if exists "Public reads campaigns" on public.campaigns;
create policy "Public reads campaigns" on public.campaigns for select using (status <> 'draft');
drop policy if exists "Authenticated creates campaigns" on public.campaigns;
create policy "Authenticated creates campaigns" on public.campaigns for insert with check (auth.uid() = created_by);
drop policy if exists "Owners manage campaigns" on public.campaigns;
create policy "Owners manage campaigns" on public.campaigns for update using (auth.uid() = created_by) with check (auth.uid() = created_by);
drop policy if exists "Members manage campaign membership" on public.campaign_members;
create policy "Members manage campaign membership" on public.campaign_members for all using (auth.uid() = user_id or public.current_user_is_admin()) with check (auth.uid() = user_id or public.current_user_is_admin());

-- Any signed-in member can report; only admins can review reports/actions.
drop policy if exists "Authenticated users create reports" on public.reports;
create policy "Authenticated users create reports" on public.reports for insert with check (auth.uid() = reporter_id);
drop policy if exists "Reporters view own reports" on public.reports;
create policy "Reporters view own reports" on public.reports for select using (auth.uid() = reporter_id);
drop policy if exists "Admins manage reports" on public.reports;
create policy "Admins manage reports" on public.reports for all using (public.current_user_is_admin()) with check (public.current_user_is_admin());
drop policy if exists "Admins manage moderation actions" on public.moderation_actions;
create policy "Admins manage moderation actions" on public.moderation_actions for all using (public.current_user_is_admin()) with check (public.current_user_is_admin());
drop policy if exists "Admins manage content revisions" on public.content_revisions;
create policy "Admins manage content revisions" on public.content_revisions for all using (public.current_user_is_admin()) with check (public.current_user_is_admin());

insert into public.roadmap_templates (id, title, detail, source_url, sort_order) values
  ('stabilize', 'Stabilize immediate needs', 'Check food, shelter, utilities, medication, and safety needs first.', 'https://ab.211.ca/', 10),
  ('programs', 'List programs that may apply', 'Review provincial, federal, disability, housing, and health-benefit options.', 'https://www.alberta.ca/alberta-supports', 20),
  ('documents', 'Gather copies, not originals', 'Collect identity, income, medical, housing, and banking documents securely.', 'https://www.alberta.ca/aish', 30),
  ('apply', 'Submit and record the application', 'Save the submission date, reference number, documents sent, and next expected step.', 'https://www.alberta.ca/income-support', 40),
  ('reasons', 'Request written reasons', 'Ask what is missing, which policy applies, and what decision was made.', 'https://www.alberta.ca/community-and-social-support-appeals', 50),
  ('deadlines', 'Track reviews and deadlines', 'Add reconsideration, appeal, accommodation, and extension dates to your journal.', 'https://www.alberta.ca/appeal-aish-decision', 60),
  ('federal', 'Check federal benefits', 'Review disability, tax, and other federal supports that may apply to your situation.', 'https://www.canada.ca/en/services/benefits.html', 70),
  ('advocate', 'Bring in support', 'Ask a trusted person, advocate, MLA office, legal referral, or support worker to join when useful.', 'https://www.legalaid.ab.ca/', 80),
  ('outcome', 'Record the outcome', 'Write what happened, what remains unresolved, and the next action you control.', 'https://www.ombudsman.ab.ca/', 90),
  ('share', 'Choose whether to share a pattern', 'Only after sanitizing details and confirming you are comfortable with public advocacy.', 'https://www.alberta.ca/advocate-persons-disabilities', 100)
on conflict (id) do update set title = excluded.title, detail = excluded.detail, source_url = excluded.source_url, sort_order = excluded.sort_order;

insert into public.manifesto_sections (slug, title, body) values
  ('main', 'Our statement', 'Alberta Unbound is a place for practical knowledge, honest disagreement, and organized public pressure. We believe people navigating poverty, disability, illness, and insecure work deserve enough support to live, clear information about the systems affecting them, and a meaningful voice in the decisions that shape their lives.')
on conflict (slug) do nothing;
