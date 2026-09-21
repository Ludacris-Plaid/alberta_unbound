# CHANGELOG

## 2026-09-20

### Security Fixes
- **CRITICAL**: Changed edge functions to use `SUPABASE_ANON_KEY` instead of `SUPABASE_SERVICE_ROLE_KEY`
- **HIGH**: Added input validation on checkout API endpoint
- **MEDIUM**: Added error handling for webhook events

### Performance Improvements
- Added database indexes for `profiles`, `subscriptions`, `blog_posts`, `threads`, `replies`, `case_logs`, and `campaign_actions`

### Bug Fixes
- Fixed hardcoded dates in schema (now uses `CURRENT_DATE - interval`)
- Fixed Stripe price calculation to use `session.current_period_end` instead of hardcoded 31 days

### Documentation
- Added `.env.example` with environment variable documentation
- Added comprehensive `README.md`
- Added `CHANGELOG.md`

### Code Quality
- Added input validation for email format and length
- Added try-catch blocks for individual webhook events
- Improved error reporting with detailed error messages

---

## Previous Versions

(To be updated as changes are made)
