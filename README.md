# ALBERTA UNBOUND — Documentation

## Overview

Alberta Unbound is a member-driven platform providing advocacy and resources for Albertans navigating disability benefits, income support, and healthcare benefits. The platform includes a members-only "The Vault" section with exclusive content.

## Technology Stack

- **Frontend**: HTML, CSS, JavaScript (client-side routing)
- **Backend**: Supabase (PostgreSQL, Auth, Realtime, Storage)
- **Stripe**: Subscription management via Edge Functions
- **Deployment**: Vercel (frontend), Supabase (backend)

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND (index.html)                    │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐              │
│  │ Homepage  │  │ Blog Posts│  │ Forum/    │              │
│  │           │  │ (Public)  │  │ Threads    │              │
│  └───────────┘  └───────────┘  └───────────┘              │
│  ┌───────────┐  ┌───────────┐                             │
│  │ The Vault │  │ User Auth │                             │
│  │ (Members) │  │            │                             │
│  └───────────┘  └───────────┘                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   SUPabase Backend                          │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐              │
│  │ PostgreSQL│  │ Auth/RLS  │  │ Storage   │              │
│  │ (Tables)  │  │ Policies   │  │ (Avatars)│              │
│  └───────────┘  └───────────┘  └───────────┘              │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   EDGE FUNCTIONS                     │   │
│  │  create-checkout  → Stripe Checkout Sessions        │   │
│  │  stripe-webhook  → Handle Stripe Webhooks           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    THIRD-PARTY SERVICES                      │
│  ┌───────────┐  ┌───────────┐                              │
│  │   Stripe  │  │  Vercel   │                              │
│  │ (Payments)│  │ (Hosting) │                              │
│  └───────────┘  └───────────┘                              │
└─────────────────────────────────────────────────────────────┘
```

## Database Schema

### Tables

- **profiles**: User profiles extending auth.users
- **subscriptions**: Stripe subscription tracking
- **blog_posts**: Public and members-only blog content
- **threads**: Forum discussion threads
- **replies**: Forum thread replies
- **case_logs**: Anonymous case submissions
- **campaign_actions**: Campaign participation tracking

### Row Level Security (RLS)

All tables use RLS policies:
- Users can view/edit their own profile
- Non-members cannot access "The Vault" content
- Forum is public read, authenticated write
- Case logs are user-specific
- Subscriptions are user-specific

## Stripe Integration

### Edge Functions

1. **create-checkout**: Creates Stripe Checkout sessions for membership
   - Input: `POST /` with `{ userId, email }`
   - Requires: `Authorization: Bearer <auth-token>`
   - Output: Session URL

2. **stripe-webhook**: Handles Stripe webhooks
   - Endpoint: `https://<project>.supabase.co/functions/v1/stripe-webhook`
   - Events: `checkout.session.completed`, `customer.subscription.*`, `invoice.payment_failed`

### Subscription Flow

1. User clicks "Join The Vault"
2. Frontend calls `create-checkout` Edge Function
3. Edge Function creates Stripe Checkout session
4. User completes Stripe checkout
5. Stripe sends webhook to Edge Function
6. Edge Function updates `profiles.is_member` flag

## Deployment

### Frontend (Vercel)

```bash
# Install dependencies
npm install

# Deploy to Vercel
vercel deploy
```

### Backend (Supabase)

```bash
# Run migrations
psql -f supabase/migrations/*.sql

# Deploy edge functions
supabase functions deploy create-checkout stripe-webhook
```

## Environment Variables

See `.env.example` for required configuration.

## Security Considerations

- ✅ Use `SUPABASE_ANON_KEY` in edge functions (not service role)
- ✅ Input validation on public APIs
- ✅ Row Level Security (RLS) policies
- ✅ Stripe webhook signature verification
- ⚠️ Add rate limiting (recommended)
- ⚠️ Add 404 pages for unknown routes (recommended)

## License

Challenge power, not put yourself in legal danger.
