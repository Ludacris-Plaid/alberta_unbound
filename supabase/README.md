# Alberta Unbound — Supabase Backend Setup

This turns the browser-only demo into a real app: real accounts, a shared forum, and the
members-only **Vault** with $10 CAD/month subscriptions.

The site code already points at your project (`bvblpeyaipjqvixamtts`) and contains the
publishable key — no code changes needed for the frontend. Do these steps in order.

---

## 1. Run the schema

1. Open your Supabase dashboard: https://supabase.com/dashboard/project/bvblpeyaipjqvixamtts
2. Go to **SQL Editor** → **New query**.
3. Paste the entire contents of [`schema.sql`](./schema.sql) and click **Run**.

This creates all tables, row-level-security policies (including the Vault paywall),
the profile auto-create trigger, and seed data (6 forum threads + replies, 4 public
blog posts, 2 placeholder Vault drops).

## 2. Verify the keys are wired in the site

`index.html` already has:

```js
const SUPABASE_URL = 'https://bvblpeyaipjqvixamtts.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_6fl5TdZvYY_yeLXqD-c_OQ_um-RQO8o';
```

The publishable key is safe in client code — it only respects the RLS policies.
The **service role key** (Settings → API keys) must **never** go in `index.html`; it's
used only inside the edge functions.

## 3. Make the site use the live backend

The site auto-detects the backend:

- **Auth** — register/login now go through Supabase Auth. Login field is your email.
- **Forum** — once the `threads`/`replies` tables respond, the forum reads/writes
  Supabase instead of localStorage.
- **The Vault** — members-only posts are filtered by RLS. Non-members get the locked UI.

If Supabase isn't reachable (e.g. schema or the workspace migration is not applied yet), the site silently falls back to localStorage demo mode. Treat that fallback as a prototype only; private workspace data is not server-persistent until the migration and RLS policies are live.

## 4. Apply the Alberta Unbound workspace migration

From the project root, after linking the Supabase project, apply the owner-scoped roadmap, journal, resources, manifesto, reporting, and campaign tables:

```bash
SUPABASE_DB_PASSWORD='your-database-password' supabase db push
supabase migration list
```

Do not put the database password, service-role key, or Stripe secrets in the repository or frontend. Test private access with two different accounts before collecting sensitive case notes.

## 5. Set up Stripe for The Vault

1. Create a Stripe account at https://stripe.com (Stripe handles GST/HST on subscriptions).
2. **Products** → create a product "Alberta Unbound Membership" with a **recurring
   price of 10.00 CAD / month**. Copy the Price id (looks like `price_1...`).
3. Install the Supabase CLI and deploy the edge functions:

```bash
npm i -g supabase
supabase login
# from this project root:
supabase functions deploy create-checkout
supabase functions deploy stripe-webhook
```

4. Set edge-function secrets (Dashboard → Edge Functions → Secrets):

| Secret | Value |
|---|---|
| `STRIPE_SECRET_KEY` | Stripe Dashboard → Developers → API keys (sk_live_... or sk_test_...) |
| `STRIPE_WEBHOOK_SECRET` | From the webhook you create in step 5 |
| `STRIPE_PRICE_ID` | The `price_1...` id from step 2 |
| `SITE_URL` | `http://127.0.0.1:8000` while testing, or your real domain |

5. Stripe Dashboard → **Developers → Webhooks** → Add endpoint:
   `https://bvblpeyaipjqvixamtts.supabase.co/functions/v1/stripe-webhook`
   Events: `checkout.session.completed`, `customer.subscription.updated`,
   `customer.subscription.deleted`, `invoice.payment_failed`.
   Copy the **Signing secret** (`whsec_...`) into `STRIPE_WEBHOOK_SECRET`.

6. Test with Stripe's test mode + test card `4242 4242 4242 4242`.

## 6. Publish your monthly Vault drops

Insert a new row in **Table Editor → blog_posts** with `is_exclusive = true`.
The site renders the `content` field verbatim (plain paragraphs, no markdown).
Members see it instantly; non-members never even see the row exists (RLS).

## 7. Security notes

- Publishable key = client-safe. Service role key = server-only (edge functions).
- The paywall is enforced in the database (RLS), not the client — there's no way to
  read exclusive posts through the API without `is_member = true`.
- Add a **CAPTCHA** (Dashboard → Auth → Bot protection) before real users arrive.
- Turn on **Email confirmation** (Dashboard → Auth) so usernames/emails are verified.

## File map

| File | Purpose |
|---|---|
| `supabase/schema.sql` | Tables, RLS, triggers, seed data |
| `supabase/functions/create-checkout/index.ts` | Stripe Checkout session (edge function) |
| `supabase/functions/stripe-webhook/index.ts` | Membership on/off via Stripe webhooks |
| `index.html` | The site — already wired to your Supabase project |

## 8. Action reminders (email)

`supabase/functions/action-reminders` sends two kinds of mail:

1. **24-hour reminder** to everyone signed up for an upcoming action (sent once).
2. **Results summary** to that roster once the action is marked completed (sent once).

### Enable it

1. Get an API key from [resend.com](https://resend.com) (free tier is fine) and set the secret:
   `supabase secrets set RESEND_API_KEY=re_xxxxxxxx --project-ref <ref>`
2. Verify your sending domain in Resend, then point the from-address at it:
   `supabase secrets set REMINDER_FROM="Alberta Unbound <actions@yourdomain.ca>"`
3. Optional hardening: `supabase secrets set CRON_SECRET=<random-string>` and add the same value as a
   GitHub repo secret — the cron job sends it in `x-cron-secret`.
4. Add repo secrets `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and (if used) `CRON_SECRET`.
   `.github/workflows/action-reminders.yml` then pings the function every hour.
5. Redeploy after editing: `supabase functions deploy action-reminders --project-ref <ref>`

Without `RESEND_API_KEY` the function still runs, records what it *would* have sent, and returns
`emailConfigured: false` — safe to schedule before the domain is verified.

Members can opt out with the **Action reminder emails** switch on their profile.
