-- Organizing platform: roles, user management, weekly action items
-- 1. profiles: role + status
alter table public.profiles add column if not exists role text not null default 'member';
alter table public.profiles add column if not exists status text not null default 'active';
alter table public.profiles add column if not exists suspended_until timestamptz;
alter table public.profiles add column if not exists suspension_reason text;

-- Sync: anyone with is_admin=true gets role='admin'
update public.profiles set role = 'admin' where is_admin = true and role <> 'admin';

-- Backfill public_profiles.role/status for the member directory (view recreated)
drop view if exists public.public_profiles;
create view public.public_profiles as
select id, username, bio, avatar, region, interests, posts_count, created_at,
       case when status = 'banned' or (status = 'suspended' and suspended_until > now()) then 'limited' else 'active' end as status
from public.profiles;

grant select on public.public_profiles to anon, authenticated;

-- 2. Helper functions (security definer so client can't spoof)
create or replace function public.current_user_role()
returns text language sql stable security definer set search_path = public as $$
  select role from public.profiles where id = auth.uid()
$$;

create or replace function public.is_mod_or_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce(role in ('mod','admin'), false) from public.profiles where id = auth.uid()
$$;

create or replace function public.user_can_post(target uuid)
returns boolean language plpgsql stable security definer set search_path = public as $$
declare p record;
begin
  if target is null then return false; end if;
  select role, status, suspended_until into p from public.profiles where id = target;
  if p.role = 'admin' then return true; end if;
  if p.status = 'banned' then return false; end if;
  if p.status = 'suspended' and p.suspended_until is not null and p.suspended_until > now() then return false; end if;
  return true;
end $$;

-- Admin-only role/status management (callable via RPC by admins)
create or replace function public.set_user_role(target uuid, new_role text)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not coalesce((select role = 'admin' from public.profiles where id = auth.uid()), false) then
    raise exception 'Only admins can change roles';
  end if;
  if new_role not in ('member','mod','admin') then raise exception 'Invalid role'; end if;
  update public.profiles set role = new_role, updated_at = now() where id = target;
  insert into public.moderation_actions (moderator_id, action, note)
  values (auth.uid(), 'role_change:' || new_role, 'target: ' || target::text);
end $$;

create or replace function public.set_user_status(target uuid, new_status text, until_ts timestamptz, reason text)
returns void language plpgsql security definer set search_path = public as $$
declare my_role text;
begin
  select role into my_role from public.profiles where id = auth.uid();
  if my_role is null or (my_role <> 'admin' and (new_status = 'banned' or new_status = 'active' or new_status = 'banned')) then
    if my_role is null or my_role not in ('mod','admin') then raise exception 'Not permitted'; end if;
  end if;
  if new_status not in ('active','suspended','banned') then raise exception 'Invalid status'; end if;
  -- Mods may only suspend/reinstate; only admins ban
  if new_status = 'banned' and my_role <> 'admin' then raise exception 'Only admins can ban'; end if;
  update public.profiles
    set status = new_status,
        suspended_until = case when new_status = 'suspended' then coalesce(until_ts, now() + interval '7 days') else null end,
        suspension_reason = case when new_status = 'active' then null else reason end,
        updated_at = now()
    where id = target;
  insert into public.moderation_actions (moderator_id, action, note)
  values (auth.uid(), 'status:' || new_status, 'target: ' || target::text || ' | reason: ' || coalesce(reason,''));
end $$;

revoke all on function public.set_user_role(uuid, text) from public;
revoke all on function public.set_user_status(uuid, text, timestamptz, text) from public;
grant execute on function public.set_user_role(uuid, text) to authenticated;
grant execute on function public.set_user_status(uuid, text, timestamptz, text) to authenticated;
grant execute on function public.current_user_role() to authenticated;
grant execute on function public.is_mod_or_admin() to authenticated;
grant execute on function public.user_can_post(uuid) to authenticated;

-- 3. Weekly action items
create table if not exists public.action_items (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  action_type text not null default 'email',
  location text not null default 'From home',
  action_at timestamptz not null,
  status text not null default 'scheduled',
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.action_signups (
  id uuid primary key default gen_random_uuid(),
  action_id uuid not null references public.action_items(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (action_id, user_id)
);

create table if not exists public.action_results (
  id uuid primary key default gen_random_uuid(),
  action_id uuid not null references public.action_items(id) on delete cascade,
  body text not null,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.action_suggestions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  action_type text not null default 'email',
  description text not null default '',
  status text not null default 'open',
  created_at timestamptz not null default now()
);

create table if not exists public.suggestion_votes (
  id uuid primary key default gen_random_uuid(),
  suggestion_id uuid not null references public.action_suggestions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (suggestion_id, user_id)
);

create index if not exists action_items_at on public.action_items (action_at desc);
create index if not exists action_signups_action on public.action_signups (action_id);

alter table public.action_items enable row level security;
alter table public.action_signups enable row level security;
alter table public.action_results enable row level security;
alter table public.action_suggestions enable row level security;
alter table public.suggestion_votes enable row level security;

-- action_items: everyone reads scheduled/completed; mods+ write
drop policy if exists "Anyone reads action items" on public.action_items;
create policy "Anyone reads action items" on public.action_items for select using (true);
drop policy if exists "Mods manage action items" on public.action_items;
create policy "Mods manage action items" on public.action_items for all
  using (public.is_mod_or_admin()) with check (public.is_mod_or_admin());

-- signups: read all (avatar stack), manage own; posters must be able to post
drop policy if exists "Anyone reads signups" on public.action_signups;
create policy "Anyone reads signups" on public.action_signups for select using (true);
drop policy if exists "Users manage own signups" on public.action_signups;
create policy "Users manage own signups" on public.action_signups for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id and public.user_can_post(auth.uid()));

-- results: read all; mods+ write
drop policy if exists "Anyone reads results" on public.action_results;
create policy "Anyone reads results" on public.action_results for select using (true);
drop policy if exists "Mods manage results" on public.action_results;
create policy "Mods manage results" on public.action_results for all
  using (public.is_mod_or_admin()) with check (public.is_mod_or_admin());

-- suggestions: read all; members create own (if they can post); mods update status
drop policy if exists "Anyone reads suggestions" on public.action_suggestions;
create policy "Anyone reads suggestions" on public.action_suggestions for select using (true);
drop policy if exists "Users create own suggestions" on public.action_suggestions;
create policy "Users create own suggestions" on public.action_suggestions for insert
  with check (auth.uid() = user_id and public.user_can_post(auth.uid()));
drop policy if exists "Users delete own suggestions" on public.action_suggestions;
create policy "Users delete own suggestions" on public.action_suggestions for delete
  using (auth.uid() = user_id or public.is_mod_or_admin());
drop policy if exists "Mods update suggestions" on public.action_suggestions;
create policy "Mods update suggestions" on public.action_suggestions for update
  using (public.is_mod_or_admin()) with check (public.is_mod_or_admin());

-- votes: read all; manage own (posters only)
drop policy if exists "Anyone reads votes" on public.suggestion_votes;
create policy "Anyone reads votes" on public.suggestion_votes for select using (true);
drop policy if exists "Users manage own votes" on public.suggestion_votes;
create policy "Users manage own votes" on public.suggestion_votes for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id and public.user_can_post(auth.uid()));

-- 4. Grant tables
grant select on public.action_items, public.action_signups, public.action_results, public.action_suggestions, public.suggestion_votes to anon, authenticated;
grant insert, update, delete on public.action_signups, public.suggestion_votes to authenticated;
grant insert on public.action_suggestions to authenticated;
grant all on public.action_items, public.action_results to authenticated;

-- Follow-up patch (pushed separately): list_members RPC + posting enforcement
create or replace function public.list_members()
returns table (
  id uuid, username text, avatar text, role text, status text,
  suspended_until timestamptz, suspension_reason text,
  posts_count integer, created_at timestamptz
) language sql stable security definer set search_path = public as $$
  select p.id, p.username, p.avatar, p.role, p.status, p.suspended_until, p.suspension_reason, p.posts_count, p.created_at
  from public.profiles p
  where public.is_mod_or_admin()
  order by p.created_at desc
$$;
grant execute on function public.list_members() to authenticated;

drop policy if exists "Users can create threads" on public.threads;
create policy "Users can create threads"
  on public.threads for insert
  with check (auth.uid() = author_id and public.user_can_post(auth.uid()));

drop policy if exists "Users can create replies" on public.replies;
create policy "Users can create replies"
  on public.replies for insert
  with check (auth.uid() = author_id and public.user_can_post(auth.uid()));
