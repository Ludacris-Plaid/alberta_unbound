-- ============================================================
-- POST MEDIA — images and short video on forum threads and replies
-- ============================================================
-- Media lives in the public 'post-media' bucket at
-- post-media/<author-uid>/<file>, and the row stores the public URL plus
-- its type. Uploads are owner-scoped: a member can only write inside
-- their own uid folder.

-- ------------------------------------------------------------
-- 1. Columns
-- ------------------------------------------------------------
alter table public.threads add column if not exists media_url  text;
alter table public.threads add column if not exists media_type text;
alter table public.replies add column if not exists media_url  text;
alter table public.replies add column if not exists media_type text;

-- ------------------------------------------------------------
-- 2. Keep the rows honest. The client validates before rendering too,
--    but a crafted API insert should not be able to store a javascript:
--    URL or a bogus type in the first place.
-- ------------------------------------------------------------
alter table public.threads drop constraint if exists threads_media_type_check;
alter table public.threads add constraint threads_media_type_check
  check (media_type is null or media_type in ('image', 'video'));

alter table public.threads drop constraint if exists threads_media_url_check;
alter table public.threads add constraint threads_media_url_check
  check (media_url is null or (media_url ~* '^https://' and char_length(media_url) <= 600));

alter table public.replies drop constraint if exists replies_media_type_check;
alter table public.replies add constraint replies_media_type_check
  check (media_type is null or media_type in ('image', 'video'));

alter table public.replies drop constraint if exists replies_media_url_check;
alter table public.replies add constraint replies_media_url_check
  check (media_url is null or (media_url ~* '^https://' and char_length(media_url) <= 600));

-- ------------------------------------------------------------
-- 3. Bucket: public read, hard caps mirroring the client-side picker
-- ------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('post-media', 'post-media', true)
on conflict (id) do update set public = true;

update storage.buckets
   set file_size_limit = 26214400,  -- 25 MB
       allowed_mime_types = array[
         'image/jpeg', 'image/png', 'image/webp', 'image/gif',
         'video/mp4', 'video/webm', 'video/quicktime'
       ]
 where id = 'post-media';

-- ------------------------------------------------------------
-- 4. Policies: anyone reads, only the owner writes their own folder
-- ------------------------------------------------------------
drop policy if exists "Post media is public" on storage.objects;
create policy "Post media is public"
  on storage.objects for select
  using (bucket_id = 'post-media');

drop policy if exists "Users upload own post media" on storage.objects;
create policy "Users upload own post media"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'post-media' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Users update own post media" on storage.objects;
create policy "Users update own post media"
  on storage.objects for update to authenticated
  using (bucket_id = 'post-media' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Users delete own post media" on storage.objects;
create policy "Users delete own post media"
  on storage.objects for delete to authenticated
  using (bucket_id = 'post-media' and (storage.foldername(name))[1] = auth.uid()::text);
