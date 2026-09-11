// Action reminders — run hourly by cron (see .github/workflows/action-reminders.yml)
// Sends: (1) a 24-hour reminder to everyone signed up for an upcoming action,
//        (2) a results summary to the roster once an action is marked completed.
// Secrets required: RESEND_API_KEY. Optional: REMINDER_FROM, SITE_URL, CRON_SECRET.
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY');
const FROM = Deno.env.get('REMINDER_FROM') ?? 'Alberta Unbound <onboarding@resend.dev>';
const SITE = Deno.env.get('SITE_URL') ?? 'https://alberta-unbound.vercel.app';
const CRON_SECRET = Deno.env.get('CRON_SECRET');

const admin = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
);

const fmtWhen = (iso: string) =>
  new Date(iso).toLocaleString('en-CA', { weekday: 'long', month: 'long', day: 'numeric', hour: 'numeric', minute: '2-digit', timeZone: 'America/Edmonton' });

async function send(to: string, subject: string, html: string) {
  if (!RESEND_API_KEY) return { ok: false, skipped: 'no RESEND_API_KEY' };
  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ from: FROM, to: [to], subject, html }),
  });
  return { ok: res.ok, status: res.status };
}

const shell = (title: string, body: string) => `
<div style="background:#0B1426;padding:28px 18px;font-family:Manrope,Helvetica,Arial,sans-serif">
  <div style="max-width:560px;margin:0 auto;background:#0F1D35;border:1px solid rgba(255,255,255,.12);border-radius:20px;overflow:hidden">
    <div style="padding:22px 26px;border-bottom:1px solid rgba(255,255,255,.10)">
      <p style="margin:0;color:#E8B33C;font-size:11px;letter-spacing:.22em;text-transform:uppercase">Alberta Unbound</p>
      <h1 style="margin:8px 0 0;color:#ffffff;font-size:20px;line-height:1.3">${title}</h1>
    </div>
    <div style="padding:22px 26px;color:#C9D4E2;font-size:15px;line-height:1.6">${body}</div>
    <div style="padding:16px 26px;border-top:1px solid rgba(255,255,255,.10);color:#7D8CA0;font-size:12px">
      You receive this because you signed up for a weekly action. Turn reminders off any time in your profile.
    </div>
  </div>
</div>`;

Deno.serve(async (req) => {
  if (CRON_SECRET && req.headers.get('x-cron-secret') !== CRON_SECRET) {
    return new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401 });
  }

  const now = new Date();
  const in24h = new Date(now.getTime() + 24 * 3600 * 1000);
  const report: Record<string, unknown>[] = [];

  // ---- 1. Upcoming actions: remind the roster 24 hours out
  const { data: due } = await admin
    .from('action_items')
    .select('id, title, description, action_at, location')
    .eq('status', 'scheduled')
    .is('reminder_sent_at', null)
    .gte('action_at', now.toISOString())
    .lte('action_at', in24h.toISOString());

  for (const action of due ?? []) {
    const { data: audience } = await admin
      .from('action_audience')
      .select('username, email, action_emails')
      .eq('action_id', action.id);

    let sent = 0;
    for (const person of audience ?? []) {
      if (!person.email || person.action_emails === false) continue;
      const r = await send(
        person.email,
        `Tomorrow: ${action.title}`,
        shell(
          escapeHtml(action.title),
          `<p>Hey ${escapeHtml(person.username)}, you're on the roster. This runs <strong>${fmtWhen(action.action_at)}</strong> (${escapeHtml(action.location ?? 'from home')}).</p>
           <p style="white-space:pre-line">${escapeHtml(action.description ?? '')}</p>
           <p><a href="${SITE}" style="color:#E8B33C">Open the action page →</a></p>`,
        ),
      );
      if (r.ok) sent++;
    }
    await admin.from('action_items').update({ reminder_sent_at: now.toISOString() }).eq('id', action.id);
    report.push({ type: 'reminder', action: action.title, sent });
  }

  // ---- 2. Completed actions: send the roster what came back
  const { data: completed } = await admin
    .from('action_items')
    .select('id, title, action_at')
    .eq('status', 'completed')
    .is('result_sent_at', null);

  for (const action of completed ?? []) {
    const [{ data: audience }, { data: results }] = await Promise.all([
      admin.from('action_audience').select('username, email, action_emails').eq('action_id', action.id),
      admin.from('action_results').select('body, created_at').eq('action_id', action.id).order('created_at', { ascending: false }),
    ]);

    let sent = 0;
    for (const person of audience ?? []) {
      if (!person.email || person.action_emails === false) continue;
      const body = (results ?? []).length
        ? (results ?? []).map((r) => `<p style="white-space:pre-line">${escapeHtml(r.body)}</p>`).join('')
        : '<p>No published result yet — the team will post what came back shortly.</p>';
      const r = await send(
        person.email,
        `What came back: ${action.title}`,
        shell(`Results · ${escapeHtml(action.title)}`, `<p>Thanks for showing up. Here is what the action produced:</p>${body}<p><a href="${SITE}" style="color:#E8B33C">See the record →</a></p>`),
      );
      if (r.ok) sent++;
    }
    await admin.from('action_items').update({ result_sent_at: now.toISOString() }).eq('id', action.id);
    report.push({ type: 'results', action: action.title, sent });
  }

  return new Response(
    JSON.stringify({ ok: true, emailConfigured: !!RESEND_API_KEY, processed: report }),
    { headers: { 'Content-Type': 'application/json' } },
  );
});

function escapeHtml(v: unknown) {
  return String(v ?? '').replace(/[&<>"']/g, (c) =>
    ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c] as string));
}
