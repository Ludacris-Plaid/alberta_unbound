-- Stats engine: accurate public counters, member momentum dashboard, admin analytics
-- All three are security-definer so the client reads a single computed payload.

-- ---- 0. Hardening: the role helpers returned NULL when unauthenticated.
--      NULL is falsy in RLS, but `if not NULL then raise` does NOT fire, which
--      made the admin_stats guard a no-op for logged-out callers.
create or replace function public.is_mod_or_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select role in ('mod','admin') from public.profiles where id = auth.uid()), false)
$$;

create or replace function public.current_user_role()
returns text language sql stable security definer set search_path = public as $$
  select coalesce((select role from public.profiles where id = auth.uid()), 'anon')
$$;

-- ============================================================
-- 1. PUBLIC STATS — safe for logged-out visitors, real numbers only
-- ============================================================
create or replace function public.public_stats()
returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'members',        (select count(*) from public.profiles),
    'guides',         (select count(*) from public.blog_posts
                        where coalesce(is_exclusive, false) = false),
    'forum_posts',    (select count(*) from public.threads)
                    + (select count(*) from public.replies),
    'threads',        (select count(*) from public.threads),
    'replies',        (select count(*) from public.replies),
    'actions_run',    (select count(*) from public.action_items where status = 'completed'),
    'actions_open',   (select count(*) from public.action_items where status <> 'completed'),
    'action_signups', (select count(*) from public.action_signups),
    'resources',      (select count(*) from public.resources where coalesce(is_published, true))
  );
$$;

grant execute on function public.public_stats() to anon, authenticated;

-- ============================================================
-- 2. MOMENTUM STATS — member-facing morale dashboard
--    Only shows aggregates that prove organizing is working.
-- ============================================================
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
        left join (select author_id, count(*) n from public.threads group by author_id) po on po.author_id = p.id
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

-- ============================================================
-- 3. ADMIN STATS — admin + mod only, complete platform picture
-- ============================================================
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
