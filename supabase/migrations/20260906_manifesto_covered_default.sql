-- ============================================================
-- Manifesto "coming soon" cover: keep the main statement covered
-- (blurred + spray-stamped) until the admin publishes it via the
-- site's toggle. RLS already enforces the gate:
--   - "Public can read published manifesto" (published = true)
--   - "Admins manage manifesto" (current_user_is_admin())
-- Visitors therefore cannot read the row while covered.
-- ============================================================

update public.manifesto_sections
set published = false
where slug = 'main';
