-- ============================================================
-- SEEDED AUTHOR PROFILES
-- ============================================================
-- The demo forum content ships with six author names that have no
-- profile row behind them, so every count that reads public.profiles
-- (member totals, standings, the scoreboard, the growth chart) ignored
-- the content that is actually on the site. This migration gives those
-- authors real rows, links their existing posts to them, and keeps
-- posts_count honest from here on.
--
-- IMPORTANT: these six are seed personas, not people. They get the
-- deterministic 5eed-* ids, a non-routable @seed.albertaunbound.invalid
-- address, no password, no confirmation, and action_emails = false, so
-- they can never sign in, never receive mail, and never be counted as
-- opted-in to action reminders. is_seeded = true marks them, and
-- admin_stats() reports real vs seeded apart so the owner always sees
-- how many accounts are actually human.
--
-- Rollback: delete from auth.users where (raw_user_meta_data->>'seeded')::boolean;
-- Profiles and badges cascade; threads/replies fall back to author_id = null.

-- ------------------------------------------------------------
-- 1. Mark seed rows
-- ------------------------------------------------------------
alter table public.profiles add column if not exists is_seeded boolean not null default false;

-- ------------------------------------------------------------
-- 2. Create the auth rows (the profile row is created by the
--    existing on_auth_user_created trigger, then filled in below).
--    created_at is backdated to just before each author's first post
--    so membership never postdates their writing.
-- ------------------------------------------------------------
with personas(name, uid, region, bio) as (
  values
    ('medicinehat_jay',    '5eed0001-0000-4000-8000-000000000001'::uuid, 'Medicine Hat, AB',
     'Medicine Hat. On Income Support between contracts, tracking every notice they send.'),
    ('reddeer_renn',       '5eed0002-0000-4000-8000-000000000002'::uuid, 'Red Deer, AB',
     'Red Deer. In the appeal queue and keeping every receipt.'),
    ('coldlake_maria',     '5eed0003-0000-4000-8000-000000000003'::uuid, 'Cold Lake, AB',
     'Cold Lake. AISH recipient. Paperwork, appointments, and the long wait.'),
    ('lethbridge_grace',   '5eed0004-0000-4000-8000-000000000004'::uuid, 'Lethbridge, AB',
     'Lethbridge. Helping a parent on AISH and learning the rules the hard way.'),
    ('yeg_streetnurse',    '5eed0005-0000-4000-8000-000000000005'::uuid, 'Edmonton, AB',
     'Edmonton. Street nurse. I see what the gaps in this system do to people.'),
    ('fortmac_tradeswife', '5eed0006-0000-4000-8000-000000000006'::uuid, 'Fort McMurray, AB',
     'Fort McMurray. Trades household. Here for the EI and retraining runarounds.')
),
firsts as (
  select p.*,
         (select min(q.created_at) from (
            select created_at from public.threads where author_name = p.name
            union all
            select created_at from public.replies where author_name = p.name
          ) q) as first_post
  from personas p
)
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, confirmation_token, recovery_token,
  email_change, email_change_token_new, email_change_token_current,
  reauthentication_token, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
)
select
  '00000000-0000-0000-0000-000000000000'::uuid,
  f.uid,
  'authenticated',
  'authenticated',
  f.name || '@seed.albertaunbound.invalid',
  null,                        -- no password: cannot sign in
  null,                        -- not confirmed: cannot recover or magic-link in
  '', '', '', '', '', '',
  jsonb_build_object('provider', 'email', 'providers', jsonb_build_array('email')),
  jsonb_build_object('username', f.name, 'seeded', true, 'region', f.region, 'bio', f.bio),
  coalesce(f.first_post, now()) - interval '2 days',
  coalesce(f.first_post, now()) - interval '2 days'
from firsts f
on conflict (id) do update
  set raw_user_meta_data = excluded.raw_user_meta_data,
      updated_at = excluded.updated_at;

-- ------------------------------------------------------------
-- 3. Fill in the profile rows the trigger just created
-- ------------------------------------------------------------
update public.profiles p
set bio          = coalesce(u.raw_user_meta_data ->> 'bio', ''),
    region       = coalesce(u.raw_user_meta_data ->> 'region', ''),
    email        = null,
    is_seeded    = true,
    is_member    = false,
    is_admin     = false,
    role         = 'member',
    status       = 'active',
    action_emails = false,     -- never mail a seed address
    member_since = u.created_at,
    created_at   = u.created_at,
    updated_at   = now()
from auth.users u
where u.id = p.id
  and (u.raw_user_meta_data ->> 'seeded')::boolean is true;

-- ------------------------------------------------------------
-- 4. posts_count: make it real, then keep it real
--    (nothing in the app ever wrote this column, so it drifted for
--    every account, not just the seed ones)
-- ------------------------------------------------------------
create or replace function public.sync_profile_post_count()
returns trigger
language plpgsql security definer set search_path = public as $$
declare
  target uuid;
begin
  target := coalesce(new.author_id, old.author_id);
  if target is not null then
    update public.profiles p
       set posts_count = (select count(*) from public.threads t where t.author_id = target)
                       + (select count(*) from public.replies r where r.author_id = target),
           updated_at = now()
     where p.id = target;
  end if;

  -- if a post moved authors, the previous author's count is now stale
  if tg_op = 'UPDATE' and old.author_id is not null
     and old.author_id is distinct from new.author_id then
    update public.profiles p
       set posts_count = (select count(*) from public.threads t where t.author_id = old.author_id)
                       + (select count(*) from public.replies r where r.author_id = old.author_id),
           updated_at = now()
     where p.id = old.author_id;
  end if;

  return null;
end $$;

drop trigger if exists sync_threads_post_count on public.threads;
create trigger sync_threads_post_count
  after insert or delete or update of author_id on public.threads
  for each row execute function public.sync_profile_post_count();

drop trigger if exists sync_replies_post_count on public.replies;
create trigger sync_replies_post_count
  after insert or delete or update of author_id on public.replies
  for each row execute function public.sync_profile_post_count();

-- ------------------------------------------------------------
-- 5. Link existing content to its author by name (author_name is the
--    source of truth: it is what posting writes). This re-points the
--    two demo replies that were attributed to the admin account, and
--    picks up older rows left with a null author_id.
-- ------------------------------------------------------------
update public.threads t
   set author_id = p.id
  from public.profiles p
 where t.author_name = p.username
   and t.author_id is distinct from p.id;

update public.replies r
   set author_id = p.id
  from public.profiles p
 where r.author_name = p.username
   and r.author_id is distinct from p.id;

-- backfill every account once, so the column is correct for all of them
update public.profiles p
   set posts_count = (select count(*) from public.threads t where t.author_id = p.id)
                   + (select count(*) from public.replies r where r.author_id = p.id);

-- ------------------------------------------------------------
-- 6. Award the forum badges these posts actually earned.
--    Same thresholds as public.award_my_badges():
--    first_voice at 1 post, coffee_row at 10.
-- ------------------------------------------------------------
insert into public.user_badges (user_id, badge_id, earned_at)
select p.id,
       'first_voice',
       coalesce((select min(x.created_at) from (
          select created_at from public.threads where author_id = p.id
          union all
          select created_at from public.replies where author_id = p.id
       ) x), now())
  from public.profiles p
 where p.posts_count >= 1
on conflict (user_id, badge_id) do nothing;

insert into public.user_badges (user_id, badge_id, earned_at)
select p.id,
       'coffee_row',
       coalesce((select min(x.created_at) from (
          select created_at from public.threads where author_id = p.id
          union all
          select created_at from public.replies where author_id = p.id
       ) x), now())
  from public.profiles p
 where p.posts_count >= 10
on conflict (user_id, badge_id) do nothing;

-- ------------------------------------------------------------
-- 7. admin_stats(): report real and seeded accounts separately so the
--    owner can always tell how much of the audience is actual people.
--    (Body otherwise identical to 20260913_stats_engine.sql.)
-- ------------------------------------------------------------
create or replace function public.admin_stats()
returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  result jsonb;
begin
  if public.is_mod_or_admin() is not true then
    raise exception 'Not authorized';
  end if;

  select jsonb_build_object(
    -- ---- Audience ----
    'audience', (
      select jsonb_build_object(
        'total',        count(*),
        'active',       count(*) filter (where status = 'active'),
        'suspended',    count(*) filter (where status = 'suspended'
                                          and coalesce(suspended_until, now()) > now()),
        'banned',       count(*) filter (where status = 'banned'),
        'new_7d',       count(*) filter (where created_at > now() - interval '7 days'),
        'new_30d',      count(*) filter (where created_at > now() - interval '30 days'),
        'admins',       count(*) filter (where role = 'admin'),
        'mods',         count(*) filter (where role = 'mod'),
        'members',      count(*) filter (where coalesce(role,'member') = 'member'),
        'real',         count(*) filter (where not is_seeded),
        'seeded',       count(*) filter (where is_seeded),
        'vault_members',count(*) filter (where is_member),
        'with_bio',     count(*) filter (where coalesce(bio,'') <> ''),
        'with_avatar',  count(*) filter (where coalesce(avatar,'') <> '')
      ) from public.profiles
    ),
    -- ---- Content ----
    'content', (
      select jsonb_build_object(
        'blog_total',      (select count(*) from public.blog_posts),
        'blog_public',     (select count(*) from public.blog_posts where coalesce(is_exclusive,false) = false),
        'blog_vault',      (select count(*) from public.blog_posts where is_exclusive),
        'threads',         (select count(*) from public.threads),
        'replies',         (select count(*) from public.replies),
        'pinned',          (select count(*) from public.threads where coalesce(pinned,false)),
        'resources',       (select count(*) from public.resources),
        'resources_live',  (select count(*) from public.resources where coalesce(is_published,true)),
        'manifesto_parts', (select count(*) from public.manifesto_sections)
      )
    ),
    -- ---- Engagement (7d / 30d activity) ----
    'engagement', (
      select jsonb_build_object(
        'threads_7d',    (select count(*) from public.threads where created_at > now() - interval '7 days'),
        'threads_30d',   (select count(*) from public.threads where created_at > now() - interval '30 days'),
        'replies_7d',    (select count(*) from public.replies where created_at > now() - interval '7 days'),
        'replies_30d',   (select count(*) from public.replies where created_at > now() - interval '30 days'),
        'badges_awarded',(select count(*) from public.user_badges),
        'badges_distinct',(select count(distinct badge_id) from public.user_badges),
        'badges_7d',     (select count(*) from public.user_badges where earned_at > now() - interval '7 days'),
        'active_posters_30d', (
          select count(distinct author_id) from (
            select author_id from public.threads where created_at > now() - interval '30 days'
            union all
            select author_id from public.replies where created_at > now() - interval '30 days'
          ) x where author_id is not null
        )
      )
    ),
    -- ---- Action engine ----
    'actions', (
      select jsonb_build_object(
        'total',          (select count(*) from public.action_items),
        'upcoming',       (select count(*) from public.action_items where status <> 'completed'),
        'completed',      (select count(*) from public.action_items where status = 'completed'),
        'next_at',        (select to_char(min(action_at), 'YYYY-MM-DD"T"HH24:MI:SSOF')
                             from public.action_items where status <> 'completed'),
        'signups_total',  (select count(*) from public.action_signups),
        'signups_30d',    (select count(*) from public.action_signups where created_at > now() - interval '30 days'),
        'unique_signers', (select count(distinct user_id) from public.action_signups),
        'avg_turnout',    (select coalesce(round(avg(n)::numeric, 1), 0) from (
                             select count(*) n from public.action_signups group by action_id
                           ) t),
        'suggestions',    (select count(*) from public.action_suggestions),
        'suggestions_open',(select count(*) from public.action_suggestions where coalesce(status,'new') <> 'promoted'),
        'suggestions_promoted',(select count(*) from public.action_suggestions where status = 'promoted'),
        'votes_cast',     (select count(*) from public.suggestion_votes),
        'results_posted', (select count(*) from public.action_results),
        'reminders_sent', (select count(*) from public.action_items where reminder_sent_at is not null),
        'results_sent',   (select count(*) from public.action_items where result_sent_at is not null),
        'reminder_optins',(select count(*) from public.profiles where coalesce(action_emails, true)),
        -- turnout per action, newest first
        'recent', coalesce((
          select jsonb_agg(row_to_json(r) order by r.action_at desc)
          from (
            select ai.id, ai.title, ai.action_type, ai.status,
                   to_char(ai.action_at, 'YYYY-MM-DD"T"HH24:MI:SSOF') as action_at,
                   (select count(*) from public.action_signups s where s.action_id = ai.id) as signups,
                   (select count(*) from public.action_results x where x.action_id = ai.id) as results
            from public.action_items ai
            order by ai.action_at desc limit 10
          ) r
        ), '[]'::jsonb)
      )
    ),
    -- ---- Case Power Desk usage ----
    'casework', jsonb_build_object(
      'timeline',  (select count(*) from public.case_timeline),
      'evidence',  (select count(*) from public.case_evidence),
      'contacts',  (select count(*) from public.case_contacts),
      'deadlines', (select count(*) from public.case_deadlines),
      'deadlines_open', (select count(*) from public.case_deadlines where not coalesce(done,false)),
      'deadlines_overdue', (select count(*) from public.case_deadlines
                             where not coalesce(done,false) and due_date < now()),
      'files_active', (select count(distinct user_id) from (
                          select user_id from public.case_timeline
                          union select user_id from public.case_evidence
                          union select user_id from public.case_contacts
                          union select user_id from public.case_deadlines
                       ) u)
    ),
    -- ---- Badge distribution ----
    'badges', coalesce((
      select jsonb_agg(row_to_json(b) order by b.awarded desc)
      from (
        select badge_id, count(*) as awarded from public.user_badges group by badge_id
      ) b
    ), '[]'::jsonb),
    -- ---- Money (Vault subscriptions) ----
    'money', (
      select jsonb_build_object(
        'vault_members',   (select count(*) from public.profiles where is_member),
        'subs_total',      (select count(*) from public.subscriptions),
        'subs_active',     (select count(*) from public.subscriptions where status = 'active'),
        'subs_trialing',   (select count(*) from public.subscriptions where status = 'trialing'),
        'subs_past_due',   (select count(*) from public.subscriptions where status = 'past_due'),
        'subs_canceled',   (select count(*) from public.subscriptions where status in ('canceled','cancelled','unpaid')),
        'mrr_cad',         (select count(*) * 10 from public.subscriptions where status in ('active','trialing')),
        'revenue_lifetime_cad', (select count(*) * 10 from public.subscriptions
                                  where status in ('active','trialing','past_due')),
        'churned_30d',     (select count(*) from public.subscriptions
                             where status in ('canceled','cancelled','unpaid')
                               and updated_at > now() - interval '30 days')
      )
    ),
    -- ---- Moderation + trust & safety ----
    'moderation', jsonb_build_object(
      'log_total',      (select count(*) from public.moderation_actions),
      'log_30d',        (select count(*) from public.moderation_actions where created_at > now() - interval '30 days'),
      'reports_open',   (select count(*) from public.reports where coalesce(status,'open') = 'open'),
      'reports_total',  (select count(*) from public.reports),
      'reports_30d',    (select count(*) from public.reports where created_at > now() - interval '30 days'),
      'suspensions_active', (select count(*) from public.profiles
                              where status = 'suspended' and coalesce(suspended_until, now()) > now()),
      'banned',         (select count(*) from public.profiles where status = 'banned'),
      'recent', coalesce((
        select jsonb_agg(row_to_json(m) order by m.created_at desc)
        from (
          select ma.action, ma.note, ma.created_at, p.username as moderator
          from public.moderation_actions ma
          left join public.profiles p on p.id = ma.moderator_id
          order by ma.created_at desc limit 8
        ) m
      ), '[]'::jsonb)
    ),
    -- ---- Traffic by week (12 weeks) ----
    'trend', coalesce((
      select jsonb_agg(row_to_json(t) order by t.week asc)
      from (
        select to_char(w.week, 'YYYY-MM-DD') as week,
               (select count(*) from public.profiles p where p.created_at >= w.week and p.created_at < w.week + interval '7 days') as new_members,
               (select count(*) from public.threads t where t.created_at >= w.week and t.created_at < w.week + interval '7 days') as threads,
               (select count(*) from public.replies r where r.created_at >= w.week and r.created_at < w.week + interval '7 days') as replies,
               (select count(*) from public.action_signups s where s.created_at >= w.week and s.created_at < w.week + interval '7 days') as signups
        from generate_series(
          date_trunc('week', now()) - interval '11 weeks',
          date_trunc('week', now()),
          interval '1 week'
        ) as w(week)
      ) t
    ), '[]'::jsonb),
    'generated_at', to_char(now(), 'YYYY-MM-DD"T"HH24:MI:SSOF')
  ) into result;
  return result;
end;
$$;

grant execute on function public.admin_stats() to authenticated;

-- ------------------------------------------------------------
-- 8. Refresh the scoreboard view (it selects p.*-derived columns, so it
--    only needs a nudge to pick up the new rows)
-- ------------------------------------------------------------
create or replace view public.member_scoreboard as
select p.id, p.username, p.avatar, p.role,
       (select count(*) from public.user_badges b where b.user_id = p.id) as badge_count,
       (select count(*) from public.action_signups s where s.user_id = p.id) as signups,
       (select count(*) from public.action_suggestions g where g.user_id = p.id) as suggestions,
       p.posts_count
from public.profiles p
where p.status = 'active';

grant select on public.member_scoreboard to anon, authenticated;

-- ------------------------------------------------------------
-- 9. momentum_stats(): the standings counted threads only, so posts
--    (and the score built from them) disagreed with the profile and
--    scoreboard columns. Count threads + replies, as everywhere else.
--    (Body otherwise identical to 20260913_stats_engine.sql.)
-- ------------------------------------------------------------
create or replace function public.momentum_stats()
returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  result jsonb;
begin
  select jsonb_build_object(
    'totals', (
      select jsonb_build_object(
        'members',         (select count(*) from public.profiles),
        'badges_awarded',  (select count(*) from public.user_badges),
        'actions_completed', (select count(*) from public.action_items where status = 'completed'),
        'actions_upcoming',  (select count(*) from public.action_items where status <> 'completed'),
        'signups_total',   (select count(*) from public.action_signups),
        'signups_done',    (select count(*) from public.action_signups s
                              join public.action_items a on a.id = s.action_id
                             where a.status = 'completed'),
        'case_entries',    (select count(*) from public.case_timeline)
                         + (select count(*) from public.case_evidence)
                         + (select count(*) from public.case_contacts)
                         + (select count(*) from public.case_deadlines),
        'forum_posts',     (select count(*) from public.threads)
                         + (select count(*) from public.replies),
        'suggestions',     (select count(*) from public.action_suggestions),
        'votes_cast',      (select count(*) from public.suggestion_votes)
      )
    ),
    -- Member standings: XP computed from badges + participation
    'leaderboard', coalesce((
      select jsonb_agg(row_to_json(t) order by t.score desc)
      from (
        select p.username, p.avatar, p.role,
               coalesce(pb.n, 0)  as badges,
               coalesce(sg.n, 0)  as actions_joined,
               coalesce(po.n, 0)  as posts,
               coalesce(ce.n, 0)  as case_entries,
               (coalesce(pb.n,0) * 10 + coalesce(sg.n,0) * 25
                + coalesce(po.n,0) * 5 + coalesce(ce.n,0) * 3) as score
        from public.profiles p
        left join (select user_id, count(*) n from public.user_badges group by user_id) pb on pb.user_id = p.id
        left join (select user_id, count(*) n from public.action_signups group by user_id) sg on sg.user_id = p.id
        left join (
          select author_id, count(*) n from (
            select author_id from public.threads
            union all
            select author_id from public.replies
          ) x where author_id is not null group by author_id
        ) po on po.author_id = p.id
        left join (select user_id, count(*) n from public.case_timeline group by user_id) ce on ce.user_id = p.id
        where p.status = 'active'
        order by score desc
        limit 15
      ) t
    ), '[]'::jsonb),
    -- Action record: every action with its turnout and results
    'timeline', coalesce((
      select jsonb_agg(row_to_json(a) order by a.action_at desc)
      from (
        select ai.id, ai.title, ai.action_type, ai.location, ai.status, ai.action_at,
               (select count(*) from public.action_signups s where s.action_id = ai.id) as turnout,
               (select count(*) from public.action_results r where r.action_id = ai.id) as results
        from public.action_items ai
        order by ai.action_at desc
        limit 12
      ) a
    ), '[]'::jsonb),
    -- Growth: members + signups per week for the last 12 weeks (sparklines)
    'growth', coalesce((
      select jsonb_agg(row_to_json(g) order by g.week asc)
      from (
        select to_char(w.week, 'YYYY-MM-DD') as week,
               (select count(*) from public.profiles p where p.created_at < w.week + interval '7 days') as members,
               (select count(*) from public.action_signups s where s.created_at < w.week + interval '7 days') as signups
        from generate_series(
          date_trunc('week', now()) - interval '11 weeks',
          date_trunc('week', now()),
          interval '1 week'
        ) as w(week)
      ) g
    ), '[]'::jsonb)
  ) into result;
  return result;
end;
$$;

grant execute on function public.momentum_stats() to authenticated;
