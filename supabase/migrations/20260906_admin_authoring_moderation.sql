-- ============================================================
-- Admin authoring + moderation tools
-- Adds: admin full control of blog_posts, thread pinning,
-- admin update/delete on threads, admin delete on replies,
-- and a moderation_actions table usable without a report FK.
-- Idempotent: safe to run multiple times.
-- ============================================================

-- 1) Blog: admins can update and delete any post
drop policy if exists "Admins manage blog posts" on public.blog_posts;
create policy "Admins manage blog posts"
  on public.blog_posts for all to authenticated
  using (public.current_user_is_admin())
  with check (public.current_user_is_admin());

-- 1b) Blog: admins can read every post, including Vault exclusives
drop policy if exists "Admins can read all posts" on public.blog_posts;
create policy "Admins can read all posts"
  on public.blog_posts for select to authenticated
  using (public.current_user_is_admin());

-- 2) Threads: admins can update (pin) and delete any thread
drop policy if exists "Admins update any thread" on public.threads;
create policy "Admins update any thread"
  on public.threads for update to authenticated
  using (public.current_user_is_admin())
  with check (public.current_user_is_admin());

drop policy if exists "Admins delete any thread" on public.threads;
create policy "Admins delete any thread"
  on public.threads for delete to authenticated
  using (public.current_user_is_admin());

-- 3) Replies: admins can delete any reply
drop policy if exists "Admins delete any reply" on public.replies;
create policy "Admins delete any reply"
  on public.replies for delete to authenticated
  using (public.current_user_is_admin());

-- 4) Thread pinning
alter table public.threads add column if not exists pinned boolean not null default false;

-- 5) Moderation log: make report_id optional so moderators can log
--    direct actions (pin/unpin/delete) without a user report.
alter table public.moderation_actions alter column report_id drop not null;

drop policy if exists "Admins manage moderation actions" on public.moderation_actions;
create policy "Admins manage moderation actions"
  on public.moderation_actions for all to authenticated
  using (public.current_user_is_admin())
  with check (public.current_user_is_admin());

-- 6) Reports: default status so client inserts never miss it
alter table public.reports alter column status set default 'open';

-- 7) Deleting a thread removes its replies (needed for admin delete)
delete from public.replies r
using public.threads t
where r.thread_id = t.id
  and not exists (
    select 1 from pg_constraint c
    where c.conrelid = 'public.replies'::regclass
      and c.contype = 'f'
      and c.confrelid = 'public.threads'::regclass
      and (pg_get_constraintdef(c.oid)) ilike '%on delete cascade%'
  );

do $$
declare
  fk_count int;
begin
  select count(*) into fk_count
  from pg_constraint c
  where c.conrelid = 'public.replies'::regclass
    and c.contype = 'f'
    and c.confrelid = 'public.threads'::regclass
    and (pg_get_constraintdef(c.oid)) ilike '%on delete cascade%';

  if fk_count = 0 then
    alter table public.replies drop constraint if exists replies_thread_id_fkey;
    alter table public.replies
      add constraint replies_thread_id_fkey
      foreign key (thread_id) references public.threads(id) on delete cascade;
  end if;
end $$;
