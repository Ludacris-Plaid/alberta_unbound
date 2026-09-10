// ============================================================
// create-checkout — Supabase Edge Function (Deno)
// Creates a Stripe Checkout session for The Vault membership.
//
// Deploy:
//   supabase functions deploy create-checkout
// Secrets (Dashboard → Edge Functions → Secrets):
//   STRIPE_SECRET_KEY
//   STRIPE_PRICE_ID   (the $10 CAD/month recurring Price id)
//   SITE_URL          (e.g. http://127.0.0.1:8000 or your domain)
// ============================================================

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@14.24.0?target=deno";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-04-10",
});
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, // service role — server side only
);

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const { userId, email } = await req.json();
    if (!userId) return new Response("Missing userId", { status: 400 });

    // Verify the caller owns this userId (defends against gifting subscriptions).
    const authHeader = req.headers.get("Authorization") || "";
    const token = authHeader.replace("Bearer ", "");
    const { data: { user } } = await supabase.auth.getUser(token);
    if (!user || user.id !== userId) {
      return new Response("Unauthorized", { status: 401 });
    }

    const priceId = Deno.env.get("STRIPE_PRICE_ID")!;
    const siteUrl = Deno.env.get("SITE_URL") || "http://127.0.0.1:8000";

    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      customer_email: email || user.email,
      line_items: [{ price: priceId, quantity: 1 }],
      client_reference_id: userId,
      metadata: { userId },
      success_url: `${siteUrl}/index.html?vault=success`,
      cancel_url: `${siteUrl}/index.html?vault=canceled`,
    });

    return new Response(JSON.stringify({ url: session.url }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("create-checkout error", err);
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
});
