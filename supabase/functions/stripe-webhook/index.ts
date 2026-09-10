// ============================================================
// stripe-webhook — Supabase Edge Function (Deno)
// Receives Stripe webhooks and flips profiles.is_member on/off.
//
// Deploy:
//   supabase functions deploy stripe-webhook
// Stripe Dashboard → Webhooks → add endpoint:
//   https://<project-ref>.supabase.co/functions/v1/stripe-webhook
//   Events: checkout.session.completed, customer.subscription.updated,
//           customer.subscription.deleted, invoice.payment_failed
// Copy the webhook signing secret into Edge Function secrets:
//   STRIPE_WEBHOOK_SECRET
// ============================================================

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@14.24.0?target=deno";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-04-10",
});
const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

serve(async (req) => {
  const signature = req.headers.get("stripe-signature");
  if (!signature) return new Response("Missing signature", { status: 400 });

  let event: Stripe.Event;
  try {
    const body = await req.text();
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      Deno.env.get("STRIPE_WEBHOOK_SECRET")!,
    );
  } catch (err) {
    console.error("webhook signature error", err);
    return new Response(`Webhook signature verification failed: ${err.message}`, { status: 400 });
  }

  const setMember = async (userId: string, active: boolean) => {
    await supabase.from("profiles").update({
      is_member: active,
      member_since: active ? new Date().toISOString() : null,
    }).eq("id", userId);
  };

  try {
    switch (event.type) {
      case "checkout.session.completed": {
        const session = event.data.object as Stripe.Checkout.Session;
        const userId = session.client_reference_id || session.metadata?.userId;
        if (userId) {
          await supabase.from("subscriptions").upsert({
            user_id: userId,
            stripe_customer_id: typeof session.customer === "string" ? session.customer : undefined,
            stripe_subscription_id: typeof session.subscription === "string" ? session.subscription : undefined,
            status: "active",
            current_period_end: session.subscription ? new Date(Date.now() + 31 * 86400e3).toISOString() : undefined,
          });
          await setMember(userId, true);
        }
        break;
      }

      case "customer.subscription.updated": {
        const sub = event.data.object as Stripe.Subscription;
        const active = sub.status === "active" || sub.status === "trialing";
        const { data: row } = await supabase.from("subscriptions")
          .select("user_id").eq("stripe_subscription_id", sub.id).maybeSingle();
        if (row) {
          await supabase.from("subscriptions").update({
            status: sub.status,
            current_period_end: new Date(sub.current_period_end * 1000).toISOString(),
          }).eq("stripe_subscription_id", sub.id);
          await setMember(row.user_id, active);
        }
        break;
      }

      case "customer.subscription.deleted": {
        const sub = event.data.object as Stripe.Subscription;
        const { data: row } = await supabase.from("subscriptions")
          .select("user_id").eq("stripe_subscription_id", sub.id).maybeSingle();
        if (row) {
          await supabase.from("subscriptions").update({ status: "canceled" })
            .eq("stripe_subscription_id", sub.id);
          await setMember(row.user_id, false);
        }
        break;
      }

      case "invoice.payment_failed": {
        const invoice = event.data.object as Stripe.Invoice;
        const subId = typeof invoice.subscription === "string" ? invoice.subscription : undefined;
        if (subId) {
          const { data: row } = await supabase.from("subscriptions")
            .select("user_id").eq("stripe_subscription_id", subId).maybeSingle();
          if (row) {
            await supabase.from("subscriptions").update({ status: "past_due" })
              .eq("stripe_subscription_id", subId);
            await setMember(row.user_id, false);
          }
        }
        break;
      }
    }
  } catch (err) {
    console.error("webhook handler error", err);
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }

  return new Response(JSON.stringify({ received: true }), { status: 200 });
});
