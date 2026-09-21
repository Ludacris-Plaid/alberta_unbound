-- ============================================================
-- ALBERTA UNBOUND — Supabase schema
-- Run this whole file in the Supabase SQL Editor (Dashboard → SQL Editor).
-- It is safe to run multiple times (CREATE ... IF NOT EXISTS).
-- ============================================================

create extension if not exists "uuid-ossp";

-- ------------------------------------------------------------
-- PROFILES (extends Supabase auth.users)
-- ------------------------------------------------------------
create table if not exists public.profiles (
  id           uuid references auth.users on delete cascade primary key,
  username     text unique not null,
  email        text,
  bio          text default '',
  avatar       text default '',
  is_member    boolean default false,
  is_admin     boolean default false,
  region       text default '',
  interests    text default '',
  member_since timestamptz,
  posts_count  integer default 0,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- Auto-create a profile row whenever someone signs up.
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'username', split_part(new.email, '@', 1)),
    new.email
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

-- Indexes for profiles table
create index if not exists idx_profiles_email on public.profiles(email);
create index if not exists idx_profiles_region on public.profiles(region);
create index if not exists idx_profiles_interests on public.profiles(interests);
create index if not exists idx_profiles_created_at on public.profiles(created_at);

-- Auto-create a trigger on auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ------------------------------------------------------------
-- SUBSCRIPTIONS (Stripe integration)
-- ------------------------------------------------------------
create table if not exists public.subscriptions (
  id                     uuid primary key default uuid_generate_v4(),
  user_id                uuid references public.profiles(id) on delete cascade not null,
  stripe_customer_id     text,
  stripe_subscription_id text unique,
  status                 text default 'inactive',  -- active | past_due | canceled | inactive
  current_period_end     timestamptz,
  created_at             timestamptz default now(),
  updated_at             timestamptz default now()
);

-- Indexes for subscriptions table
create index if not exists idx_subscriptions_user_id on public.subscriptions(user_id);
create index if not exists idx_subscriptions_status on public.subscriptions(status);
create index if not exists idx_subscriptions_created_at on public.subscriptions(created_at);

-- ------------------------------------------------------------
-- BLOG POSTS (public + exclusive "Vault" drops)
-- ------------------------------------------------------------
create table if not exists public.blog_posts (
  id           uuid primary key default uuid_generate_v4(),
  title        text not null,
  category     text not null,
  excerpt      text not null default '',
  content      text not null,
  is_exclusive boolean default false,      -- true = The Vault (members only)
  published_at date default current_date,
  read_time    text default '5 min read',
  created_at   timestamptz default now()
);

-- Indexes for blog_posts table
create index if not exists idx_blog_posts_category on public.blog_posts(category);
create index if not exists idx_blog_posts_is_exclusive on public.blog_posts(is_exclusive);
create index if not exists idx_blog_posts_published_at on public.blog_posts(published_at);
create index if not exists idx_blog_posts_title on public.blog_posts(title);

-- ------------------------------------------------------------
-- FORUM
-- ------------------------------------------------------------
create table if not exists public.threads (
  id          bigserial primary key,
  title       text not null,
  category    text not null,
  author_id   uuid references public.profiles(id) on delete set null,
  author_name text not null,
  content     text not null,
  created_at  timestamptz default now()
);

create table if not exists public.replies (
  id          bigserial primary key,
  thread_id   bigint references public.threads(id) on delete cascade not null,
  author_id   uuid references public.profiles(id) on delete set null,
  author_name text not null,
  content     text not null,
  created_at  timestamptz default now()
);

-- Indexes for threads table
create index if not exists idx_threads_category on public.threads(category);
create index if not exists idx_threads_author_id on public.threads(author_id);
create index if not exists idx_threads_created_at on public.threads(created_at);
create index if not exists idx_threads_title on public.threads(title);

-- Indexes for replies table
create index if not exists idx_replies_thread_id on public.replies(thread_id);
create index if not exists idx_replies_author_id on public.replies(author_id);
create index if not exists idx_replies_created_at on public.replies(created_at);

-- ------------------------------------------------------------
-- CASE WORKSPACE + CAMPAIGNS (optional, future backend)
-- ------------------------------------------------------------
create table if not exists public.case_logs (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid references public.profiles(id) on delete cascade,
  program     text not null,
  issue       text not null,
  outcome     text default '',
  details     text default '',
  is_anonymous boolean default false,
  created_at  timestamptz default now()
);

-- Indexes for case_logs table
create index if not exists idx_case_logs_user_id on public.case_logs(user_id);
create index if not exists idx_case_logs_program on public.case_logs(program);
create index if not exists idx_case_logs_created_at on public.case_logs(created_at);

-- Indexes for campaign_actions table
create index if not exists idx_campaign_actions_user_id on public.campaign_actions(user_id);
create index if not exists idx_campaign_actions_campaign_id on public.campaign_actions(campaign_id);
create index if not exists idx_campaign_actions_completed_at on public.campaign_actions(completed_at);

-- Indexes for case_logs table
create index if not exists idx_case_logs_user_id on public.case_logs(user_id);
create index if not exists idx_case_logs_program on public.case_logs(program);
create index if not exists idx_case_logs_created_at on public.case_logs(created_at);

-- ------------------------------------------------------------
-- ROW LEVEL SECURITY
-- ------------------------------------------------------------
alter table public.profiles        enable row level security;
alter table public.subscriptions   enable row level security;
alter table public.blog_posts      enable row level security;
alter table public.threads         enable row level security;
alter table public.replies         enable row level security;
alter table public.case_logs       enable row level security;
alter table public.campaign_actions enable row level security;

create or replace function public.current_user_is_admin()
returns boolean
language sql
stable
security definer
set search_path = public, pg_catalog
as $$
  select exists (select 1 from public.profiles where id = auth.uid() and is_admin = true);
$$;
create or replace function public.profile_flag_value(target_id uuid, flag_name text)
returns boolean
language plpgsql
stable
security definer
set search_path = public, pg_catalog
as $$
declare result boolean;
begin
  if auth.uid() is null or auth.uid() <> target_id then raise exception 'Own profile only';
  elsif flag_name = 'is_member' then select is_member into result from public.profiles where id = target_id;
  elsif flag_name = 'is_admin' then select is_admin into result from public.profiles where id = target_id;
  else raise exception 'Unsupported profile flag';
  end if;
  return coalesce(result, false);
end;
$$;
revoke all on function public.current_user_is_admin() from public;
grant execute on function public.current_user_is_admin() to anon, authenticated;
revoke all on function public.profile_flag_value(uuid, text) from public;
grant execute on function public.profile_flag_value(uuid, text) to authenticated;

drop policy if exists "Public profiles are viewable by everyone" on public.profiles;
create policy "Users can view own profile"
  on public.profiles for select using (auth.uid() = id or public.current_user_is_admin());

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles for update using (auth.uid() = id)
  with check (
    auth.uid() = id
    and is_member = public.profile_flag_value(auth.uid(), 'is_member')
    and is_admin = public.profile_flag_value(auth.uid(), 'is_admin')
  );

drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile"
  on public.profiles for insert with check (auth.uid() = id);

-- The Vault paywall: non-members can't even see exclusive rows exist.
drop policy if exists "Anyone can read non-exclusive posts" on public.blog_posts;
create policy "Anyone can read non-exclusive posts"
  on public.blog_posts for select using (is_exclusive = false);

drop policy if exists "Members can read exclusive posts" on public.blog_posts;
create policy "Members can read exclusive posts"
  on public.blog_posts for select
  using (
    is_exclusive = true
    and exists (select 1 from public.profiles where id = auth.uid() and is_member = true)
  );

drop policy if exists "Authenticated users can write posts" on public.blog_posts;
create policy "Authenticated users can write posts"
  on public.blog_posts for insert with check (auth.uid() is not null);

drop policy if exists "Anyone can read threads" on public.threads;
create policy "Anyone can read threads"
  on public.threads for select using (true);

drop policy if exists "Authenticated users can create threads" on public.threads;
create policy "Authenticated users can create threads"
  on public.threads for insert with check (auth.uid() = author_id);

drop policy if exists "Anyone can read replies" on public.replies;
create policy "Anyone can read replies"
  on public.replies for select using (true);

drop policy if exists "Authenticated users can create replies" on public.replies;
create policy "Authenticated users can create replies"
  on public.replies for insert with check (auth.uid() = author_id);

drop policy if exists "Users can view own case logs" on public.case_logs;
create policy "Users can view own case logs"
  on public.case_logs for select using (auth.uid() = user_id);

drop policy if exists "Users can create case logs" on public.case_logs;
create policy "Users can create case logs"
  on public.case_logs for insert with check (auth.uid() = user_id);

drop policy if exists "Users manage own campaign actions" on public.campaign_actions;
create policy "Users manage own campaign actions"
  on public.campaign_actions for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users can view own subscription" on public.subscriptions;
create policy "Users can view own subscription"
  on public.subscriptions for select using (auth.uid() = user_id);

-- ------------------------------------------------------------
-- SEED: forum threads + replies (same content as the site demo)
-- ------------------------------------------------------------
insert into public.threads (id, title, category, author_name, content, created_at) values
  (1, 'AISH to ADAP — a $200/month cut disguised as a "transition"', 'adap', 'admin', 'Got my letter. They''re calling it a "transition." It''s a $200/month cut to disabled Albertans while this province is sitting on a $5.5 billion surplus. The "transition benefit" keeps payments level until January 2028 — then everyone drops to $1,740. The trade-off is supposedly higher income exemptions, but most of us can''t work. This isn''t reform. This is theft with extra paperwork. Who else is furious?', CURRENT_DATE - interval '3 days'),
  (2, 'Income Support wait times: 4 weeks and counting. This is by design.', 'incomesupport', 'admin', 'Four weeks waiting for Income Support. 90 minutes on hold at 1-877-644-9992 just to hear "it''s being processed." Rent is due in 3 days. The system isn''t slow because it''s underfunded — it''s slow because they want you to give up. Anyone else stuck in this nightmare? What''s actually worked to get movement?', CURRENT_DATE - interval '5 days'),
  (3, 'AISH denied after 5 months. What helped people appeal?', 'appeals', 'admin', 'Waited five months. Doctor confirmed permanent disability. Medical panel still said no. The Auditor General has described how persistence affects outcomes. I have 30 days and I am collecting the written reasons, asking questions, and looking for support. Who has been through this and what helped?', CURRENT_DATE - interval '8 days'),
  (4, 'Alberta Adult Health Benefit: they''ll pull your teeth but won''t crown them', 'health', 'admin', 'Just got the AAHB card. The brochure is intentionally vague about dental. Fillings? Root canals? Crowns? I''ve got a tooth that''s been killing me for months. I know they cover extractions — because pulling a tooth is cheaper than saving one. Has anyone actually gotten something beyond basic fillings approved?', CURRENT_DATE - interval '12 days'),
  (5, 'The 6-month Income Support cap — what should people document?', 'incomesupport', 'admin', 'The government introduced a 6-month cap for some people assessed as employable. I am trying to understand the current rules, what notices people receive, and which review or accommodation routes may apply. Has anyone reached this point and documented what happened?', CURRENT_DATE - interval '15 days'),
  (6, 'Applying for AISH/ADAP: the step-by-step guide the government won''t give you', 'aish', 'admin', 'They make the process confusing on purpose. Here''s the real guide: (1) Call Alberta Supports at 1-877-644-9992 or visit a centre in person. (2) You''ll need your health care number, SIN, banking info, and — crucially — medical documentation where your doctor clearly states your condition is PERMANENT and prevents you from earning a living. Doctors often write vague letters — don''t let them. Those exact words matter. (3) Expect 3-6 months of waiting. (4) Expect to be denied the first time. (5) When denied, appeal immediately. This system is a gauntlet. We''ll help you through it.', CURRENT_DATE - interval '20 days')
on conflict (id) do nothing;

insert into public.replies (thread_id, author_name, content, created_at) values
  (1, 'admin', 'You should be furious. Here''s the brutal math: AISH pays $1,940. ADAP pays $1,740. Unless you can earn $2,136+/month from work (which most disabled people can''t), you''re losing $200/month — $2,400/year — while the government brags about surplus. The transition benefit is just buying them time to hope you forget. Don''t. Call your MLA. Post here. Share your story. The only way this gets reversed is if we make enough noise.', CURRENT_DATE - interval '2 days'),
  (2, 'admin', 'The official line is 2 weeks. Reality is 4-6. Here''s what actually works: (1) Upload EVERY document at once — partial submissions are their favorite excuse to delay. (2) If you''re facing eviction or utility cutoff, use the word "emergency" — they have an expedited process they conveniently don''t advertise. (3) Call at exactly 7:30 AM when lines open. (4) Get your MLA involved — caseworkers move faster when an elected official is asking questions.', CURRENT_DATE - interval '4 days'),
  (2, 'admin', 'If you have ANY medical condition that limits your ability to work, demand a Barriers to Full Employment (BFE) assessment. Higher payment, more stability, and the 6-month cap works differently. The caseworker won''t volunteer this — you have to ask.', CURRENT_DATE - interval '3 days'),
  (3, 'admin', 'They denied you because the system is BUILT to deny you. Most successful AISH recipients were denied the first time. Here''s the winning strategy: (1) Demand the full medical panel report — you have a right to see exactly why they denied you. (2) Get your doctor to write a letter addressing each denial reason point by point. (3) Get letters from every specialist, occupational therapist, and social worker who knows your case. (4) Write a personal impact statement — be specific about what you can''t do and how your life is affected. (5) Submit EVERYTHING in writing within 30 days. Do not miss the deadline — they are counting on it.', CURRENT_DATE - interval '7 days'),
  (4, 'admin', 'AAHB has specific coverage limits for dental services. Ask your provider about predetermination and whether a medically necessary exception process may apply. Keep every receipt and written response, and compare the current official coverage details before booking treatment.', CURRENT_DATE - interval '11 days'),
  (6, 'admin', 'Critical update: as of July 2026, new applicants go into ADAP at $1,740/month — $200 less than grandfathered AISH recipients. Same exhausting process, less money, fewer appeal rights. If you''re already on AISH, the $200 transition benefit keeps you at $1,940 until January 2028. The government is betting you won''t organize in time. Prove them wrong.', CURRENT_DATE - interval '19 days');

-- ------------------------------------------------------------
-- SEED: public blog posts
-- ------------------------------------------------------------
insert into public.blog_posts (title, category, excerpt, content, published_at, read_time, is_exclusive) values
  ('AISH to ADAP: What the July 2026 Transition Means for You', 'Disability Benefits',
   'A plain-language look at the ADAP transition, the payment questions, and the support routes worth checking.',
   'On July 1, 2026, Alberta launched the Alberta Disability Assistance Program (ADAP). Separate current program information from advocacy analysis, read your transition letter, compare the payment details that apply to you, and connect with an advocate or official support route when you need help.',
   CURRENT_DATE - interval '31 days', '8 min read', false),
  ('How to Apply for Alberta Income Support: A Complete Walkthrough', 'Income Support',
   'The 6-month cap can be difficult to navigate. Here''s how to prepare, document your application, and find emergency assistance.',
   'Five steps: (1) gather documents — health care number, SIN, banking info, and medical notes stating your condition is PERMANENT. (2) Apply online or in person at Alberta Supports, 1-877-644-9992. (3) Expect an interview. (4) Expect 2-6 weeks of waiting. (5) If denied, appeal within 30 days. If you face eviction or disconnection, use the word "emergency" — an expedited process exists. If any medical condition limits work, demand a Barriers to Full Employment (BFE) assessment; the 6-month cap works differently for you. Never submit originals. Keep copies of everything.',
   CURRENT_DATE - interval '45 days', '6 min read', false),
  ('AISH Denied? Here''s Your Appeal Strategy', 'Appeals',
   'A practical guide to requesting reasons, gathering support, and meeting the appeal deadline.',
   'Start by requesting the written reasons and relevant file materials. Ask your doctor or care team to address each reason clearly, gather relevant supporting letters, describe the impact on daily functioning, and submit your response in writing within the stated deadline. Consider bringing an advocate or trusted supporter.',
   CURRENT_DATE - interval '65 days', '7 min read', false),
  ('Alberta Health Benefits: Know the Gaps, Request Exceptions', 'Health Benefits',
   'Understand coverage limits, ask about predetermination, and document medically necessary exception requests.',
   'The Alberta Adult Health Benefit has specific coverage limits for dental, prescriptions, and optical services. Ask your provider about predetermination and whether a medically necessary exception process may apply. Keep every receipt and written response.',
   CURRENT_DATE - interval '85 days', '5 min read', false);

-- ------------------------------------------------------------
-- SEED: The Vault (members-only) — REPLACE the content below with
-- your actual monthly drops. The site renders `content` verbatim.
-- Keep it legal: the site's own line is "challenge power, not
-- put yourself in legal danger."
-- ------------------------------------------------------------
insert into public.blog_posts (title, category, excerpt, content, published_at, read_time, is_exclusive) values
  ('Field note 001 — Exceptional-needs requests', 'The Vault',
   'One paragraph in the policy manual unlocks funds caseworkers never mention.',
   'This members-only field note explains how to ask about exceptional-needs funding, request the applicable policy in writing, describe a concrete urgent need, and keep a clear record of the response. It focuses on lawful requests, documentation, and follow-up. Verify current policy and eligibility before acting.',
   CURRENT_DATE - interval '60 days', '4 min read', true),
  ('Field note 002 — Building a reconsideration record', 'The Vault',
   'What "reconsideration" really means, and how to use every lawful pause in the clock.',
   'This members-only field note explains how to request written reasons, identify the applicable review route, ask for an extension before a deadline, and organize a factual reconsideration record. It does not replace official instructions or legal advice.',
   CURRENT_DATE - interval '30 days', '4 min read', true);

-- Done. Next: deploy the edge functions (see supabase/functions/ and README.md).
