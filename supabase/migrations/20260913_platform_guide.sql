-- Platform guide: comprehensive member onboarding post pinned to top
INSERT INTO public.blog_posts (id, title, category, excerpt, content, is_exclusive, published_at, read_time, created_at)
VALUES (
  gen_random_uuid(),
  'Your Complete Platform Guide: Every Tool, Every Strategy, Every Advantage',
  'Start Here',
  'This is your manual. Every feature on Alberta Unbound — the Case Diary, the forum, the action engine, the resources — explained step by step so you can use this platform to its full power.',
  false,
  '2026-12-15',
  '12 min',
  now()
)
ON CONFLICT (id) DO NOTHING;

-- Now update the content with the full guide HTML
UPDATE public.blog_posts
SET content = $GUIDE_HTML$
WHERE title = 'Your Complete Platform Guide: Every Tool, Every Strategy, Every Advantage';
