-- Badges, levels, and action reminders
-- 1. Badge storage (public flex, awardable only through the server RPC)
create table if not exists public.user_badges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  badge_id text not null,
  earned_at timestamptz not null default now(),
  unique (user_id, badge_id)
);
create index if not exists user_badges_user on public.user_badges (user_id);

alter table public.user_badges enable row level security;

drop policy if exists "Anyone reads badges" on public.user_badges;
create policy "Anyone reads badges" on public.user_badges for select using (true);

grant select on public.user_badges to anon, authenticated;

-- 2. Award RPC: self-only, computes every criterion from real activity.
--    Users cannot award themselves badges directly — only this function can insert.
create or replace function public.award_my_badges()
returns table (badge_id text, earned_at timestamptz)
language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  v_bio boolean; v_avatar boolean;
  v_threads int; v_replies int; v_posts int;
  v_timeline int; v_evidence int; v_contacts int; v_deadlines int;
  v_signups int; v_suggestions int; v_promoted int; v_votes int; v_showed int;
  v_role text; v_rank int; v_actions_with_results int;
begin
  if uid is null then raise exception 'Not authenticated'; end if;

  select coalesce(bio, '') <> '', coalesce(avatar, '') <> ''
    into v_bio, v_avatar from public.profiles where id = uid;

  select count(*) into v_threads from public.threads where author_id = uid;
  select count(*) into v_replies from public.replies where author_id = uid;
  v_posts := coalesce(v_threads, 0) + coalesce(v_replies, 0);

  select count(*) into v_timeline from public.case_timeline where user_id = uid;
  select count(*) into v_evidence from public.case_evidence where user_id = uid;
  select count(*) into v_contacts from public.case_contacts where user_id = uid;
  select count(*) into v_deadlines from public.case_deadlines where user_id = uid;

  select count(*) into v_signups from public.action_signups where user_id = uid;
  select count(*) into v_suggestions from public.action_suggestions where user_id = uid;
  select count(*) into v_promoted from public.action_suggestions where user_id = uid and status = 'promoted';
  select count(*) into v_votes from public.suggestion_votes where user_id = uid;
  select count(*) into v_showed
    from public.action_signups s join public.action_items i on i.id = s.action_id
    where s.user_id = uid and i.status = 'completed';
  select count(*) into v_actions_with_results
    from public.action_results r join public.action_signups s on s.action_id = r.action_id
    where s.user_id = uid;

  select role into v_role from public.profiles where id = uid;
  select count(*) into v_rank from public.profiles p
    where p.created_at <= (select created_at from public.profiles where id = uid);

  -- profile
  if v_bio and v_avatar then
    insert into public.user_badges (user_id, badge_id) values (uid, 'profile_complete') on conflict do nothing;
  end if;
  -- forum
  if v_posts >= 1 then insert into public.user_badges (user_id, badge_id) values (uid, 'first_voice') on conflict do nothing; end if;
  if v_posts >= 10 then insert into public.user_badges (user_id, badge_id) values (uid, 'coffee_row') on conflict do nothing; end if;
  if v_posts >= 50 then insert into public.user_badges (user_id, badge_id) values (uid, 'town_hall') on conflict do nothing; end if;
  -- case file
  if v_timeline >= 1 then insert into public.user_badges (user_id, badge_id) values (uid, 'paper_trail') on conflict do nothing; end if;
  if v_timeline >= 10 and v_evidence >= 3 then insert into public.user_badges (user_id, badge_id) values (uid, 'case_keeper') on conflict do nothing; end if;
  if v_evidence >= 10 then insert into public.user_badges (user_id, badge_id) values (uid, 'evidence_locker') on conflict do nothing; end if;
  if v_contacts >= 5 then insert into public.user_badges (user_id, badge_id) values (uid, 'rolodex') on conflict do nothing; end if;
  if v_deadlines >= 3 then insert into public.user_badges (user_id, badge_id) values (uid, 'deadline_watch') on conflict do nothing; end if;
  -- actions
  if v_signups >= 1 then insert into public.user_badges (user_id, badge_id) values (uid, 'signed_on') on conflict do nothing; end if;
  if v_signups >= 3 then insert into public.user_badges (user_id, badge_id) values (uid, 'rally_hand') on conflict do nothing; end if;
  if v_signups >= 10 then insert into public.user_badges (user_id, badge_id) values (uid, 'roughneck') on conflict do nothing; end if;
  if v_showed >= 1 then insert into public.user_badges (user_id, badge_id) values (uid, 'showed_up') on conflict do nothing; end if;
  if v_actions_with_results >= 1 then insert into public.user_badges (user_id, badge_id) values (uid, 'receipts') on conflict do nothing; end if;
  if v_suggestions >= 1 then insert into public.user_badges (user_id, badge_id) values (uid, 'pitcher') on conflict do nothing; end if;
  if v_promoted >= 1 then insert into public.user_badges (user_id, badge_id) values (uid, 'whip') on conflict do nothing; end if;
  if v_votes >= 5 then insert into public.user_badges (user_id, badge_id) values (uid, 'seconder') on conflict do nothing; end if;
  -- roles and standing
  if v_role = 'mod' or v_role = 'admin' then insert into public.user_badges (user_id, badge_id) values (uid, 'steward') on conflict do nothing; end if;
  if v_role = 'admin' then insert into public.user_badges (user_id, badge_id) values (uid, 'chair') on conflict do nothing; end if;
  if v_rank <= 50 then insert into public.user_badges (user_id, badge_id) values (uid, 'founder') on conflict do nothing; end if;

  return query select ub.badge_id, ub.earned_at from public.user_badges ub
    where ub.user_id = uid order by ub.earned_at asc;
end $$;

revoke all on function public.award_my_badges() from public;
grant execute on function public.award_my_badges() to authenticated;

-- 3. Scoreboard for the leaderboard (aggregates only, no private data)
create or replace view public.member_scoreboard as
select p.id, p.username, p.avatar, p.role,
       (select count(*) from public.user_badges b where b.user_id = p.id) as badge_count,
       (select count(*) from public.action_signups s where s.user_id = p.id) as signups,
       (select count(*) from public.action_suggestions g where g.user_id = p.id) as suggestions,
       p.posts_count
from public.profiles p
where p.status = 'active';

grant select on public.member_scoreboard to anon, authenticated;

-- 4. Reminder bookkeeping for the email function
alter table public.action_items add column if not exists reminder_sent_at timestamptz;
alter table public.action_items add column if not exists result_sent_at timestamptz;

-- Opt-out flag on profiles (defaults on)
alter table public.profiles add column if not exists action_emails boolean not null default true;

-- 5. Signups view for the reminder function (function uses the service role, so this is just convenience)
create or replace view public.action_audience as
select s.action_id, s.user_id, p.username, p.email, p.action_emails
from public.action_signups s
join public.profiles p on p.id = s.user_id;
grant select on public.action_audience to authenticated;
