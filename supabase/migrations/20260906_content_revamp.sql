-- ============================================================
-- CONTENT REVAMP: full rewrite of guides & forum
-- 2026-09-06 · author of record: dysthemix (admin)
-- ============================================================

create extension if not exists "pgcrypto";

-- 2) REWRITE BLOG POSTS ----------------------------------------------
-- Full researched guides. Content is trusted admin-authored HTML.
-- Weekly cadence on Wednesdays, backdated 2026-04-01 → 2026-09-02.

update public.blog_posts set
  title = 'The Income Support Reality Check: What You Actually Get in 2026',
  category = 'Income Support',
  excerpt = 'Core Essential $479. Core Shelter up to $339. We ran the real numbers against real Alberta rents, and built the application walkthrough the government never wrote.',
  read_time = '14 min read',
  published_at = '2026-08-26',
  content = '<p class="text-lg leading-relaxed mb-6">Income Support is Alberta&rsquo;s program of last resort, and it pays a single &ldquo;expected to work&rdquo; adult a combination of Core Essential and Core Shelter benefits that totals, at maximum, under <strong>$900 a month</strong>. Read that again. Under nine hundred dollars, in a province where the average one-bedroom rents for over $1,400 in Calgary and $1,300+ in Edmonton. This guide shows the real math, then walks the application so you do not leave money on the table.</p>

<div class="gw gw-stats" aria-label="Income Support numbers">
  <div class="gw-stat"><div class="gw-stat-value" data-count="479" data-prefix="$">$479</div><div class="gw-stat-label">Core Essential, single adult</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="339" data-prefix="≤$">≤$339</div><div class="gw-stat-label">Core Shelter cap, single</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="818" data-prefix="$">$818</div><div class="gw-stat-label">Best case, per month</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="1400" data-prefix="~$">~$1,400</div><div class="gw-stat-label">Avg 1-bed rent, Calgary</div></div>
</div>

<div class="gw gw-callout c-red" role="note">
  <div class="gw-callout-tag">The gap is the policy</div>
  <p>Rates rose 4.25% with inflation, but Alberta rents rose far faster over the same years — 1-bedroom Calgary averaged $1,776 at the 2025 peak and sits around $1,467 mid-2026 even after cooling. The <strong>shelter benefit cap ($260–$339 for singles)</strong> has not come within sight of market rent in a decade. Everyone receiving Income Support covers the difference from the food budget. That is not a personal failure; it is arithmetic the government refuses to do.</p>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">The two streams — and why the stream decides your survival</h3>
<div class="gw gw-table-wrap"><table class="gw-table">
  <thead><tr><th></th><th>Expected to Work (ETW)</th><th>Barriers to Full Employment (BFE)</th></tr></thead>
  <tbody>
    <tr><td class="font-semibold">Who it&rsquo;s for</td><td>Short-term: actively job-seeking or working under-income</td><td>Chronic medical/psychological barriers to employment</td></tr>
    <tr><td class="font-semibold">Time limit</td><td><strong>6-month cap</strong> if not meeting expectations (Budget 2026)</td><td>No monthly cap while barrier persists</td></tr>
    <tr><td class="font-semibold">Total, single adult</td><td>~$818/mo max</td><td>Higher core rates + stability</td></tr>
    <tr><td class="font-semibold">Requires</td><td>Job search log, attendance at employment services</td><td>Medical documentation of the barrier</td></tr>
  </tbody>
</table></div>
<p class="leading-relaxed mt-4 mb-4">If you have <em>any</em> diagnosed condition that limits your ability to work — mental health, chronic pain, long COVID, addiction history, learning disability — <strong>request a BFE assessment in writing at application time</strong>. Caseworkers do not offer it; you must ask. BFE clients are exempt from the worst of the 6-month enforcement and the rate is meaningfully higher. One sentence in one letter can be worth over a thousand dollars a year.</p>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">The application, done right</h3>
<div class="gw gw-steps" aria-label="Application steps">
  <div class="gw-step"><div><h4>Gather the file before you first call</h4><p>Alberta health care number, SIN, photo ID, banking info, proof of address (lease or landlord letter), 60 days of bank statements for every account, income records, and — if claiming a medical barrier — the <strong>Income Support Medical Assessment form (EMP0409)</strong> from your doctor or nurse practitioner. Missing documents are the single biggest source of delays.</p></div></div>
  <div class="gw-step"><div><h4>Apply through the right door</h4><p>Online via <strong>MyAlberta Supports</strong>, or by phone at <strong>1-877-644-9992</strong> (Mon–Fri 7:30 am–8 pm). In immediate crisis, the <strong>24-hour Income Support Contact Centre: 1-866-644-5135</strong> can issue emergency food/transportation/medication benefits — and you can now receive emergency food via Interac e-Transfer after a phone assessment.</p></div></div>
  <div class="gw-step"><div><h4>The intake interview: be complete, not brief</h4><p>Their job is to document why you cannot meet basic needs. Do not minimize — if you skipped meals to pay rent, say exactly that, in those words. Everything becomes part of your file, and your file is what an appeal panel reads later.</p></div></div>
  <div class="gw-step"><div><h4>Claim every supplemental benefit you qualify for</h4><p>The Financial Benefits Summary includes: <strong>special diets</strong> ($26–$132/mo by condition), <strong>earnings replacement</strong>, <strong>child care</strong>, <strong>school expenses</strong>, <strong>utility connection/arrears</strong>, <strong>damage deposits</strong>, <strong>essential household items</strong>, and <strong>funeral benefits</strong>. Most recipients receive none of these because nobody mentions them. Ask for the full list in writing and self-assess line by line.</p></div></div>
  <div class="gw-step"><div><h4>Document everything, forever</h4><p>Date, time, name, and badge/employee number of every worker you speak to. Every conversation gets a follow-up note in your journal (the site&rsquo;s Case Power Desk has one built in). The day a caseworker tells you something wrong, your contemporaneous notes are what win the appeal.</p></div></div>
</div>

<div class="gw gw-deadline" role="alert">
  <div class="gw-pulse" aria-hidden="true"></div>
  <p><strong>The 6-month cap is real.</strong> Budget 2026 caps ETW clients &ldquo;not meeting program expectations&rdquo; at six months of benefits. The protections are: a written notice before any cut-off, the right to appeal to the Citizens&rsquo; Appeal Panel within 30 days, and medical exemption through BFE status. If you get a cap notice, do not wait — the appeal deadline runs from the day you <em>received</em> the decision.</p>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">Working while on Income Support</h3>
<p class="leading-relaxed mb-4">You keep all of your wages; only a portion counts against your benefit calculation. ETW singles have a <strong>$230/month earnings exemption</strong> before benefits taper, and there are work-related expense supports (transportation, boots, tools, licensing fees) that caseworkers rarely volunteer. Reporting income honestly and on time is non-negotiable — an unreported earnings overpayment gets clawed back at source and can end in prosecution. Reporting everything and claiming every exemption you are entitled to is how you legally keep the most money.</p>

<div class="gw gw-callout" role="note">
  <div class="gw-callout-tag">Emergency numbers that actually answer</div>
  <p><strong>24-hour Income Support Contact Centre:</strong> 1-866-644-5135 (food, medication, shelter, transportation emergencies — pre-apply online at MyAlberta Emergency Benefits, then phone). <strong>Alberta Supports:</strong> 1-877-644-9992. Facing eviction? Tell them the word <strong>eviction</strong> in the first sentence — it routes you to the emergency stream with same-day assessment options. <strong>Edmonton/Calgary eviction prevention</strong> also runs through program-specific rent banks listed on our Resources page.</p>
</div>'
where title = 'How to Apply for Alberta Income Support: A Complete Walkthrough';

-- (2c) Health benefits — replaces the old AAHB post
update public.blog_posts set
  title = 'Your Alberta Health Benefits, Line by Line: AAHB, AISH Coverage, and the Exception Route',
  category = 'Health Benefits',
  excerpt = 'Dental limits, glasses every 24 months, the drug list, and the exception committee almost nobody uses. What your card actually covers — and how to fight for what it should.',
  read_time = '13 min read',
  published_at = '2026-08-12',
  content = '<p class="text-lg leading-relaxed mb-6">Every benefit card in Alberta — AISH, ADAP, Income Support, and the Alberta Adult Health Benefit (AAHB) — carries a health plan administered through Alberta Blue Cross. Most cardholders use a fraction of it, because the coverage rules live in documents nobody hands you. This guide maps the coverage, the limits, and the exception processes that turn a “no” into a “maybe.”</p>

<div class="gw gw-stats" aria-label="Coverage snapshot">
  <div class="gw-stat"><div class="gw-stat-value" data-count="24" data-suffix=" mo">24 mo</div><div class="gw-stat-label">Eye exam + glasses cycle, adults</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="12" data-suffix=" mo">12 mo</div><div class="gw-stat-label">Glasses for kids under 19</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="3000" data-suffix="+">3,000</div><div class="gw-stat-label">Max test strips/year by regimen</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="16580" data-prefix="$">$16,580</div><div class="gw-stat-label">AAHB income limit, single</div></div>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">Who qualifies for AAHB (the card most people have never heard of)</h3>
<p class="leading-relaxed mb-4">The AAHB covers low-income Albertans who are <strong>pregnant or have high ongoing prescription drug needs</strong> — plus people leaving Income Support or AISH due to employment or CPP-D income. Income limits (net, family-size based, off your tax return Line 23600 minus annual drug costs): single adult <strong>$16,580</strong>, couple <strong>$23,212</strong>, plus roughly $5,000–$6,000 per child. Coverage: dental, prescription drugs, eye exams and glasses, emergency ambulance, essential diabetes supplies, and some OTC medications. Apply with form <strong>AEHB3931</strong>; every September the province re-checks income with the CRA and auto-renews you if you still qualify.</p>

<div class="gw gw-callout c-blue" role="note">
  <div class="gw-callout-tag">Stack your dental coverage</div>
  <p>AAHB dental now coordinates with the <strong>federal Canadian Dental Care Plan (CDCP)</strong>: claims go to CDCP first, and AAHB picks up remaining eligible costs. If you are 65+, or qualify for the CDCP by other criteria, enroll in both. Also: if you have any private plan, it pays first — AAHB is always the payer of last resort.</p>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">What is actually covered</h3>
<div class="gw gw-table-wrap"><table class="gw-table">
  <thead><tr><th>Service</th><th>Coverage</th><th>The fine print</th></tr></thead>
  <tbody>
    <tr><td class="font-semibold">Dental basics</td><td>Exams, x-rays, cleaning, fillings, extractions, dentures</td><td>Annual exam cycle; predetermination required for major work</td></tr>
    <tr><td class="font-semibold">Root canals</td><td>Limited</td><td>Anterior (front) teeth standard; molars need exception approval</td></tr>
    <tr><td class="font-semibold">Crowns</td><td>Exception only</td><td>Requires Health Benefits Exception Committee sign-off with dental justification</td></tr>
    <tr><td class="font-semibold">Eye care</td><td>Exam + glasses every 24 months (adults)</td><td>Kids under 19: glasses yearly; contact lenses by exception</td></tr>
    <tr><td class="font-semibold">Prescriptions</td><td>Alberta Drug Benefit List</td><td>Interactive DBL online; OTC only if listed (prenatal vitamins, children&rsquo;s vitamins)</td></tr>
    <tr><td class="font-semibold">Ambulance</td><td>Emergency trips to nearest hospital</td><td>Interfacility and non-emergency transfers are different programs</td></tr>
    <tr><td class="font-semibold">Diabetes supplies</td><td>Strips (up to 3,000/yr), lancets, CGMs by criteria</td><td>Benefit year runs July 1–June 30; CGM approval adjusts strip limits</td></tr>
  </tbody>
</table></div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">The exception route: how “not covered” becomes “covered”</h3>
<p class="leading-relaxed mb-4">For anything outside the standard basket — a molar root canal, a crown, a non-formulary drug — the path is a written exception request supported by your prescriber. The mechanics:</p>
<div class="gw gw-steps" aria-label="Exception process">
  <div class="gw-step"><div><h4>Get the clinical justification letter first</h4><p>Your dentist or doctor writes why the standard-covered alternative will not work — failed prior treatment, medical contraindication, or documented risk. “Patient prefers” wins nothing; “two failed root canals on record, extraction would destabilize adjacent bridgework” does.</p></div></div>
  <div class="gw-step"><div><h4>File predetermination before treatment, not after</h4><p>Your provider submits the treatment plan to Alberta Blue Cross for predetermination. Never book major work before the answer comes back in writing. Post-treatment approvals are rare; pre-approvals are the normal channel.</p></div></div>
  <div class="gw-step"><div><h4>Escalate a denial with new evidence</h4><p>A flat denial with no new information will not change on re-submit. But new clinical evidence — a failed procedure, a specialist letter, changed medications — reopens it. Ask the program, in writing, what evidence would change the outcome. They sometimes answer, and the answer is gold.</p></div></div>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">AISH and ADAP health coverage specifics</h3>
<p class="leading-relaxed mb-4">AISH/ADAP clients keep health benefits <strong>regardless of employment income</strong> — that guarantee survived the 2026 transition and is the strongest feature of the new program. Coverage mirrors the AAHB basket (dental, optical, prescriptions, ambulance, diabetes supplies) plus personal-benefits extras like special diets and medical equipment through distinct channels. The one universal warning: <strong>coverage rules change at program boundaries</strong> — transitioning from Income Support to AISH to ADAP is exactly when claims get denied because the plan of record changed mid-treatment. Verify before scheduling anything elective in a transition window.</p>

<div class="gw gw-callout" role="note">
  <div class="gw-callout-tag">Who to call</div>
  <p><strong>AAHB program:</strong> through Alberta Supports 1-877-644-9992 or your caseworker. <strong>Alberta Blue Cross</strong> (card/claims questions): 780-498-8000 or 1-800-661-6995. <strong>Exception requests:</strong> your provider submits; you follow up through the program office. <strong>CDCP:</strong> canada.ca/dental-care. Keep every predetermination letter — they are your coverage history.</p>
</div>'
where title = 'Alberta Health Benefits: Know the Gaps, Fight the Exceptions';

-- (3) NEW POST 1 — Rent & housing crisis guide
insert into public.blog_posts (title, category, excerpt, content, is_exclusive, published_at, read_time)
values (
  'The Rent Reality: Every Housing Program an Albertan on Benefits Can Actually Use',
  'Housing & Rent',
  'Shelter caps versus real rents, the Rent Assistance Benefit, the temporary benefit, damage-deposit help, and how to answer an eviction without panicking.',
  '<p class="text-lg leading-relaxed mb-6">The single shelter benefit for a single adult on Income Support caps out around <strong>$339/month</strong>. Average rent for a one-bedroom in Calgary sits near <strong>$1,467</strong> (mid-2026, and that is <em>after</em> a year of cooling). Edmonton runs a couple hundred lower; Fort McMurray, Grande Prairie and Canmore run higher. That gap — five hundred to a thousand dollars a month — is the central math problem of poverty in Alberta. Here is every program that attacks it, in the order you should try them.</p>

<div class="gw gw-bars" aria-label="Rent versus shelter benefit">
  <div class="gw-bars-title">Monthly cost of a 1-bedroom vs. maximum shelter benefit (2026, approx.)</div>
  <div class="gw-bar-row"><div class="gw-bar-head"><span>Calgary average 1-bed rent</span><strong>$1,467</strong></div><div class="gw-bar-track"><div class="gw-bar-fill g-red" style="--w:1"></div></div></div>
  <div class="gw-bar-row"><div class="gw-bar-head"><span>Edmonton average 1-bed rent</span><strong>$1,280</strong></div><div class="gw-bar-track"><div class="gw-bar-fill g-red" style="--w:.87"></div></div></div>
  <div class="gw-bar-row"><div class="gw-bar-head"><span>Income Support shelter cap (single)</span><strong>$339</strong></div><div class="gw-bar-track"><div class="gw-bar-fill g-gold" style="--w:.23"></div></div></div>
  <div class="gw-bar-row"><div class="gw-bar-head"><span>AISH covers it — because living allowance pays rent too</span><strong>$1,940 all-in</strong></div><div class="gw-bar-track"><div class="gw-bar-fill g-blue" style="--w:.75"></div></div></div>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">Tier 1: The Rent Assistance Benefit (RAB) — long-term, the real one</h3>
<p class="leading-relaxed mb-4">The RAB is a <strong>long-term monthly subsidy paid directly to you</strong>, calculated as the gap between roughly 30% of your household income and a local market-rent benchmark, capped by bedroom count (roughly $400–$900+ depending on household size and community). It renews annually with no lifetime limit while you remain eligible. You apply through your local <strong>housing management body</strong> (Civida in Edmonton, The City of Calgary/Housing Company, Homeland Housing, etc.) via the province&rsquo;s Find Housing tool. Priority goes by need, and waitlists are real — apply the moment you anticipate needing it, not after the crisis starts.</p>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">Tier 2: The Temporary Rent Assistance Benefit (TRAB)</h3>
<p class="leading-relaxed mb-4">For <strong>working</strong> households with low income — employed within the last 24 months and <em>not</em> on Income Support/AISH — TRAB pays a time-limited subsidy (2-year max, reduced in year two, first-come first-served) in Calgary, Edmonton, Fort McMurray, Grande Prairie, Lethbridge, Medicine Hat, Red Deer and surrounding communities. If you are on Income Support you cannot get TRAB — but you can get <strong>RAB</strong>, and moving to work later can bridge you onto TRAB for up to two years.</p>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">Tier 3: The one-time tools inside Income Support</h3>
<ul class="space-y-3 mb-6">
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>Damage deposit benefit</strong> — pays the security deposit directly when you are starting a tenancy (repayable arrangement). Getting a unit often hinges on having first-and-last; this is the official tool for it.</span></li>
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>Utility arrears / connection</strong> — prevents disconnection or restores service; pair it with the utility companies&rsquo; own payment plans (they must offer one before disconnecting).</span></li>
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>Emergency Needs Allowance</strong> — for imminent homelessness, the 24-hour line (1-866-644-5135) can authorize temporary shelter and other crisis benefits, even by phone at 2 am.</span></li>
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>Money left after rent rule</strong> — if your actual rent exceeds the shelter cap, Income Support is supposed to top up from the basic allowance so essentials remain. Verify your calculation; this is misapplied more often than you would think.</span></li>
</ul>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">When the landlord moves: eviction response, step by step</h3>
<div class="gw gw-steps" aria-label="Eviction response">
  <div class="gw-step"><div><h4>Read the notice for defects</h4><p>Alberta evictions require written notice with specific contents (reason, date, signature). A defective notice can be challenged. Most common: verbal evictions (not legal), notices with wrong dates, retaliation for requesting repairs.</p></div></div>
  <div class="gw-step"><div><h4>Know the timeline</h4><p>Substantial-breach notices typically give 14 days to fix or leave; landlords then apply to RTDRS or court for a termination order. You do not have to move on day 15 — only an order can remove you. That buys time to negotiate or relocate.</p></div></div>
  <div class="gw-step"><div><h4>File with RTDRS if you dispute</h4><p>The <strong>Residential Tenancy Dispute Resolution Service</strong> is faster and cheaper than court ($50 filing, waivable in financial hardship applications). Tenants can also file against landlords: illegal entry, unpaid deposits, repair failures.</p></div></div>
  <div class="gw-step"><div><h4>Line up the emergency money</h4><p>Eviction-prevention funds exist in most cities (rent banks, Inn From the Cold, Bissell Centre, CSS Calgary). Income Support can issue emergency benefits. Landlords often accept a payment plan backed by a caseworker letter — tell your worker the word &ldquo;eviction&rdquo; in the first sentence.</p></div></div>
</div>

<div class="gw gw-callout" role="note" style="margin-top:2.5rem">
  <div class="gw-callout-tag">The numbers, in one breath</div>
  <p>RAB application: through your local housing management body (find via alberta.ca Find Housing tool). TRAB: same bodies, working households only. Emergency: 1-866-644-5135 (24 h). RTDRS: alberta.ca/rtdrs, $50 filing, fee waivers available. Tenant/landlord info line: 1-877-427-4088. Service Alberta consumer Contact Centre handles tenancy questions Monday–Friday.</p>
</div>',
  false, '2026-08-05', '11 min read'
);

-- (4) NEW POST 2 — CPP-D + CDB stacking
insert into public.blog_posts (title, category, excerpt, content, is_exclusive, published_at, read_time)
values (
  'Stack the Federal Money: CPP-D, the Canada Disability Benefit, and the Disability Tax Credit',
  'Federal Benefits',
  'The average CPP-D cheque beats the AISH living allowance. The CDB pays $200/month. The DTC unlocks both plus yearly tax refunds. Most Albertans claim none of them.',
  '<p class="text-lg leading-relaxed mb-6">Every conversation about Alberta benefits is incomplete without the federal layer. For contributors to the Canada Pension Plan, the disability pension alone averaged <strong>$1,191.72/month</strong> for new recipients in 2026 — with a maximum of <strong>$1,741.20</strong> plus <strong>$307.81 per child</strong>. That is real money that does not reduce your Alberta benefits the way people assume. Here is the federal stack and how the clawbacks actually work.</p>

<div class="gw gw-stats" aria-label="Federal benefit amounts 2026">
  <div class="gw-stat"><div class="gw-stat-value" data-count="1741.20" data-prefix="$">$1,741.20</div><div class="gw-stat-label">CPP-D max, monthly (2026)</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="1191.72" data-prefix="$">$1,191.72</div><div class="gw-stat-label">CPP-D average, new recipients</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="200" data-prefix="$">$200</div><div class="gw-stat-label">Canada Disability Benefit, max</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="307.81" data-prefix="+$">+$307.81</div><div class="gw-stat-label">CPP-D per eligible child</div></div>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">CPP-D: the pension you already paid for</h3>
<p class="leading-relaxed mb-4">If you worked in Canada and contributed for roughly 4 of the last 6 years, you may qualify for CPP-D: a pension for severe <em>and prolonged</em> disability that renders you <strong>incapable regularly of pursuing any substantially gainful occupation</strong>. Key facts the brochures skip:</p>
<ul class="space-y-3 mb-6">
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>The medical bar is high but different from AISH.</strong> CPP-D asks whether you can work at <em>any</em> substantially gainful job, considering age, education and experience. A denial from one program does not predict the other — people denied AISH win CPP-D and vice versa.</span></li>
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>You have 12 months</strong> from the date of disability to apply without contribution-credit complications — but late applicants can still qualify under the drop-out provisions. Apply even if you think you are late.</span></li>
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>Denied?</strong> Reconsideration within 90 days, then the Social Security Tribunal (General Division) — where appellants regularly win with proper medical evidence. Free to appeal at every level.</span></li>
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>Ask Service Canada to pay your doctor.</strong> The medical report for CPP-D is a formal invoice item — Service Canada reimburses physicians (about $85–$175 by complexity). Tell your doctor&rsquo;s office this; some clinics refuse forms until they learn the billing exists.</span></li>
</ul>

<div class="gw gw-callout c-blue" role="note">
  <div class="gw-callout-tag">How CPP-D interacts with AISH/ADAP</div>
  <p>CPP-D is counted as income, but AISH/ADAP does not disappear — it tops up. Because CPP-D exceeds the AISH living allowance for most recipients, AISH may reduce to a smaller top-up plus you keep full health benefits. Net effect: <strong>your total monthly income usually rises by hundreds of dollars</strong>. Applying is a requirement of both programs anyway (AISH can cut benefits for refusing to apply for CPP-D). File it.</p>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">The Canada Disability Benefit: $200/month with a catch (or two)</h3>
<p class="leading-relaxed mb-4">The CDB is the new federal benefit: up to <strong>$200/month ($2,400/year)</strong>, paid the third Thursday, indexed to inflation, requires the <strong>Disability Tax Credit</strong> as a gateway. The catches: Alberta <strong>claws it back dollar-for-dollar</strong> from AISH/ADAP payments, and it can interact with other benefits. Why apply anyway: (1) the fall 2026 one-time <strong>$150 supplement</strong>; (2) the clawback debate is live and could change — enrolment now protects you; (3) non-AISH recipients (working poor with disabilities, CPP-D recipients) can keep some or all of it; (4) the DTC gateway itself is worth thousands regardless.</p>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">The Disability Tax Credit: the master key</h3>
<p class="leading-relaxed mb-4">The DTC is not a cheque — it is eligibility infrastructure. Form T2201 (your practitioner marks which functions are markedly restricted), and approval unlocks: the DTC tax refund (retroactive up to 10 years — commonly <strong>$1,500–$3,000+</strong> total), the Registered Disability Savings Plan (grants and bonds up to <strong>$90,000</strong> lifetime in government money for low-income filers), the CDB, the working-income top-up for disabled workers, and caregiver credit transfers. Approval rate for well-documented applications is high; the forms are the barrier, and our Resources page template covers them.</p>

<div class="gw gw-steps" aria-label="Federal filing order">
  <div class="gw-step"><div><h4>File the T2201 (DTC) first</h4><p>Everything federal keys off it. Your practitioner completes the functional section; you file to CRA. Sixteen-plus week processing; call to check status, and ask about the retroactive window.</p></div></div>
  <div class="gw-step"><div><h4>Then the CDB application</h4><p>Online via My Service Canada Account, or paper. Requires DTC approval. Payments third Thursday of each month; the month after approval starts the clock.</p></div></div>
  <div class="gw-step"><div><h4>CPP-D application in parallel</h4><p>Do not wait for the DTC. Different program, different evidence stream. Your ASPS/ISP-1151 medical report is billed to Service Canada — do not pay out of pocket for the standard report.</p></div></div>
  <div class="gw-step"><div><h4>Report every approval to AISH/ADAP — required</h4><p>ADAP clients must report CDB and DTC outcomes. Do it in writing and keep the confirmation. Undeclared income becomes an overpayment later; declared income becomes a correctly calculated top-up today.</p></div></div>
</div>

<div class="gw gw-callout" role="note" style="margin-top:2.5rem">
  <div class="gw-callout-tag">Contacts</div>
  <p><strong>CPP-D:</strong> 1-800-277-9914 (Service Canada). <strong>CDB:</strong> through Service Canada, same line. <strong>DTC:</strong> CRA 1-800-959-8281. <strong>RDSP:</strong> through any bank or credit union with the DTC. Free help with appeals: <strong>Service Canada&rsquo;s</strong> reconsideration is internal; <strong>SST appeals</strong> often benefit from community legal clinics — Calgary Legal Guidance and Edmonton Community Legal Centre both take CPP-D cases.</p>
</div>',
  false, '2026-07-29', '12 min read'
);

-- (5) NEW POST 3 — Overpayment defense
insert into public.blog_posts (title, category, excerpt, content, is_exclusive, published_at, read_time)
values (
  'They Say You Owe Money: The Overpayment Defense Manual',
  'Appeals',
  'Overpayment notices arrive without warning and demand repayment from people who have nothing. Here is what the notice must contain, your four legal responses, and how the appeal math works.',
  '<p class="text-lg leading-relaxed mb-6">An overpayment notice says the government paid you money you were not eligible for — usually because a worker misapplied a rule, income was reported late, or a household change was processed wrong. The letter arrives months after the fact, states a four-figure debt, and starts automatic clawbacks from a budget that cannot spare them. Overpayments are among the most <em>appealed</em> and most <em>reversed</em> decisions in the system, because the errors are usually the government&rsquo;s. Here is the defense.</p>

<div class="gw gw-deadline" role="alert">
  <div class="gw-pulse" aria-hidden="true"></div>
  <p><strong>Appeal deadline: 30 days from when you received the overpayment decision.</strong> Filing an appeal generally pauses aggressive collection while the matter is live — and if you miss the window, the extension request (AISH Act s. 10(4); equivalent IES provisions for Income Support) exists for exactly this. Act within days of the letter, not weeks.</p>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">First: make them prove it</h3>
<p class="leading-relaxed mb-4">An overpayment is a claim. The program holds the burden of showing you were ineligible and by how much. In writing, request <strong>three things</strong>: (1) the complete calculation sheet showing every month and every dollar they claim; (2) the <strong>policy or regulation section</strong> they applied to each month; (3) your file for the period in question (FOIP request — free for your own personal information). Roughly one in three files I have seen contains an arithmetic or date error that changes the total. You cannot find it without the calculation sheet.</p>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">Your four responses, ranked</h3>
<div class="gw gw-table-wrap"><table class="gw-table">
  <thead><tr><th>Response</th><th>When it fits</th><th>Effect</th></tr></thead>
  <tbody>
    <tr><td class="font-semibold">1. Dispute the amount</td><td>Math errors, wrong months, double-counted income, wrong rates applied</td><td>Debt reduced or erased at appeal</td></tr>
    <tr><td class="font-semibold">2. Dispute the law</td><td>They applied the wrong rule, or misapplied a household/income change</td><td>Debt erased at appeal</td></tr>
    <tr><td class="font-semibold">3. Claim relief from recovery</td><td>Debt is technically valid but collection causes hardship, or you relied on their written error</td><td>Recovery reduced, suspended, or written off</td></tr>
    <tr><td class="font-semibold">4. Negotiate the rate</td><td>Debt stands but the clawback exceeds the standard percentage</td><td>Smaller monthly recovery</td></tr>
  </tbody>
</table></div>

<div class="gw gw-callout c-blue" role="note">
  <div class="gw-callout-tag">The reliance argument</div>
  <p>If a worker told you — in writing, or noted in your file — that an amount was approved, and you spent it in good faith before the reversal, that is <strong>reliance on official error</strong>. Decision-makers have discretion to waive or reduce recovery in these cases, and appeal panels see it as fair. Your contemporaneous notes and their letters are the entire case — which is why this site keeps telling you to document every conversation.</p>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">What recovery looks like if the debt stands</h3>
<p class="leading-relaxed mb-4">For current clients, recovery is normally a percentage deduction from ongoing benefits — there are standard rates, and deductions beyond them can be contested on hardship grounds. For former clients, the debt goes to collections or tax-setoff. Practical notes: (1) you can <strong>propose a repayment schedule</strong> in writing — a realistic one gets accepted more often than a defiant zero; (2) never ignore the letter — default leads to automatic clawback at aggressive rates; (3) an <strong>underpayment discovered at the same time offsets the overpayment</strong> — audit your own payments for the same period and claim every dollar they shorted you.</p>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">Filing the appeal</h3>
<div class="gw gw-steps" aria-label="Overpayment appeal steps">
  <div class="gw-step"><div><h4>Get the right form</h4><p>AISH decisions use the AISH Notice of Appeal; Income Support decisions use the IES (Income and Employment Supports) appeal form. Both on alberta.ca via the Appeals Secretariat forms page. A letter works in a pinch — same contents as any appeal: what decision, when received, why it is wrong, signature.</p></div></div>
  <div class="gw-step"><div><h4>Send it where it lands</h4><p>Email <strong>ALSS.Appeals@gov.ab.ca</strong> or fax 780-422-1088. Phone for help: 780-427-2709 (Edmonton) / 403-297-5636 (Calgary). Keep proof of sending and the acknowledgement letter.</p></div></div>
  <div class="gw-step"><div><h4>Build the binder</h4><p>Chronological: every payment statement for the disputed period, every letter, the calculation sheet they owe you, your bank records showing what actually arrived, and your journal notes. Panels are persuaded by organized people because organized files are checkable.</p></div></div>
  <div class="gw-step"><div><h4>Keep receiving — and reporting — normally</h4><p>Do not stop reporting income or changes during the dispute; a second overpayment while appealing the first is the worst position in the system. Appeal the debt, comply with everything else.</p></div></div>
</div>

<div class="gw gw-stats" aria-label="Overpayment defense essentials" style="margin-top:2.5rem">
  <div class="gw-stat"><div class="gw-stat-value" data-count="30" data-suffix=" days">30 days</div><div class="gw-stat-label">To file the appeal</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="3">3 documents</div><div class="gw-stat-label">They must give you on request</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="0" data-prefix="$">$0</div><div class="gw-stat-label">Cost of any appeal</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="1" data-suffix=" audit">1 audit</div><div class="gw-stat-label">Of your own payments — claim underpayments</div></div>
</div>',
  false, '2026-07-22', '10 min read'
);

-- (6) NEW POST 4 — FOIP power guide
insert into public.blog_posts (title, category, excerpt, content, is_exclusive, published_at, read_time)
values (
  'Your File Is a Weapon: Using FOIP to Get Every Word the Government Wrote About You',
  'Self-Advocacy',
  'Free for your own records. Binding 30-day deadline. Gets internal notes you would never otherwise see. The Freedom of Information request is the most underused tool in poverty advocacy.',
  '<p class="text-lg leading-relaxed mb-6">Every decision made about your benefits was written down somewhere — intake notes, worker assessments, internal emails, the medical panel&rsquo;s actual words, the policy manual section they relied on. Under Alberta&rsquo;s access law you can demand all of it, <strong>free of charge for your own personal information</strong>, on a legally binding timeline. People who read their files win appeals at higher rates, catch calculation errors, and see worker errors in black and white. Here is the complete mechanics.</p>

<div class="gw gw-stats" aria-label="FOIP facts">
  <div class="gw-stat"><div class="gw-stat-value" data-count="0" data-prefix="$">$0</div><div class="gw-stat-label">Fee for your own personal info</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="30" data-suffix=" days">30 days</div><div class="gw-stat-label">Legal response deadline</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="2005" data-suffix="">2005</div><div class="gw-stat-label">FOIP Act in force since</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="1" data-suffix=" form">1 form</div><div class="gw-stat-label">Everything starts with one</div></div>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">What you can get</h3>
<ul class="space-y-3 mb-6">
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>Your complete AISH/ADAP/Income Support file</strong> — applications, worker notes, decision records, calculation sheets, scanned letters (including ones you never received).</span></li>
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>The medical panel report</strong> in full — the exact reasoning of the panel that denied you. This is the single most valuable document in an appeal.</span></li>
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>Internal policy interpretations</strong> — manuals and directives can be requested; program policy manuals are also increasingly published on alberta.ca (the Income Support policy manual is online).</span></li>
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>Correspondence about you</strong> between offices — emails are records too, and worker-to-worker messages frequently contain the candid assessment that contradicts the official letter.</span></li>
</ul>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">How to file one, precisely</h3>
<div class="gw gw-steps" aria-label="FOIP filing steps">
  <div class="gw-step"><div><h4>Address it to the right public body</h4><p>For benefits files: the <strong>Ministry of Assisted Living and Social Services</strong> (AISH, ADAP, Income Support). Alberta Health for health records, Alberta Blue Cross for claims. The generic Request to Access Information form (alberta.ca) lets you name the body and describe records.</p></div></div>
  <div class="gw-step"><div><h4>Describe records broadly but concretely</h4><p>Weak: “my file.” Strong: “all records in my client file from January 1, 2024 to present, including intake notes, worker assessments, medical panel reports, calculation sheets, internal correspondence concerning me, and recordings of calls, for the period of my application and all subsequent decisions.” Specific enough to search, broad enough to catch everything.</p></div></div>
  <div class="gw-step"><div><h4>State the access route</h4><p>You can request copies by mail/email or inspection. Ask for electronic copies — faster, free to send, and you get searchable PDFs.</p></div></div>
  <div class="gw-step"><div><h4>Calendar the deadline and enforce it</h4><p>The body must respond within <strong>30 calendar days</strong>. Extensions require written notice with reasons. No response? A deemed refusal lets you complain to the <strong>Office of the Information and Privacy Commissioner (OIPC)</strong> — oipc.ab.ca — which investigates for free.</p></div></div>
  <div class="gw-step"><div><h4>Read it like an adversary file</h4><p>Mark every factual error, every unsupported conclusion, every internal contradiction. Errors get corrected through a correction request (your right under the Act), and contradictions become cross-examination material in appeals. This is how one quiet request turns into leverage.</p></div></div>
</div>

<div class="gw gw-callout c-red" role="note">
  <div class="gw-callout-tag">What FOIP will not do</div>
  <p>It will not delete records you dislike (you can request <em>corrections</em>, noted alongside, not erasure), it will not speed up your appeal (file the appeal on time regardless), and third-party information (another person&rsquo;s personal data) will be severed. Also: fees can apply to <em>general</em> (non-personal) requests — but requests for your own personal information are free unless volume copying is extraordinary.</p>
</div>

<div class="gw gw-callout" role="note">
  <div class="gw-callout-tag">Contacts</div>
  <p><strong>Access requests:</strong> alberta.ca/access-to-information-requests (form + ministry FOIP contacts). <strong>OIPC complaints:</strong> oipc.ab.ca, 780-422-6860 or 1-888-878-4044. <strong>Your own program file:</strong> also ask the program directly — FOIP is the enforceable backstop when the casual ask stalls.</p>
</div>',
  false, '2026-07-15', '9 min read'
);

-- (7) NEW POST 5 — Emergency benefits playbook
insert into public.blog_posts (title, category, excerpt, content, is_exclusive, published_at, read_time)
values (
  'The 2 AM Playbook: Emergency Benefits That Answer When Everything Falls Apart',
  'Income Support',
  'Eviction notice on a Friday, fridge empty on a Sunday, medication held at the pharmacy. The emergency stream has money, it answers 24 hours a day, and now it can e-Transfer you. Know it before you need it.',
  '<p class="text-lg leading-relaxed mb-6">Beneath the regular programs runs an emergency stream most recipients learn about only in crisis: the <strong>Emergency Needs Allowance</strong> and the 24-hour Income Support Contact Centre. It exists for the moment the situation is unforeseeable, presents a severe health risk, and cannot wait for the next cheque. This is the playbook for that moment — written before you need it, because at 2 am you will not be researching.</p>

<div class="gw gw-callout c-red" role="alert">
  <div class="gw-callout-tag">Save these numbers now</div>
  <p><strong>24-hour Income Support Contact Centre: 1-866-644-5135.</strong> Answers 24/7, every day of the year. <strong>MyAlberta Emergency Benefits</strong> (emergencybenefits.alberta.ca) — pre-apply online for food, transportation and medical supplies, then phone to complete the assessment. <strong>Alberta Supports (daytime): 1-877-644-9992</strong>, 7:30 am–8 pm. Put all three in your phone today.</p>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">What qualifies as an emergency (their words)</h3>
<p class="leading-relaxed mb-4">The official test: a situation <strong>caused by unforeseeable circumstances beyond your control</strong>, that <strong>presents a severe health risk</strong>, where you <strong>cannot access other resources or wait</strong> for your next pay or benefit cheque. In practice the assessed categories are: <strong>food, medication, medical supplies, temporary shelter, and transportation</strong>. Emergency benefits are one-time, short-term (about a month), and do not become ongoing income.</p>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">The new fast lane: e-Transfer food benefits</h3>
<p class="leading-relaxed mb-4">The province now issues emergency food benefits by <strong>Interac e-Transfer</strong>: start the application at MyAlberta Emergency Benefits online, then call the 24-hour centre to confirm eligibility and complete the assessment. No card pickup, no office visit, no waiting for a cheque in the mail. For anyone without a vehicle in a city the size of Edmonton or Calgary at night, this is the difference between eating and not.</p>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">The scripts for the three big crises</h3>
<div class="gw gw-steps" aria-label="Crisis scripts">
  <div class="gw-step"><div><h4>Eviction notice</h4><p>First sentence: “I have received an eviction notice and I need emergency assistance to prevent homelessness.” Name the date on the notice. Ask for the <strong>emergency shelter/utility benefits</strong> and a referral to eviction prevention. Also tell your regular caseworker the same day — the daytime office can do more (rent arrears, deposit) than the after-hours stream.</p></div></div>
  <div class="gw-step"><div><h4>Utility disconnection</h4><p>“My power is scheduled for disconnection and I have medication in the fridge / medical equipment that requires power.” Disconnection triggers the emergency stream, and remember: Alberta utilities must offer a payment plan before disconnecting — ask the utility for it while the emergency application runs.</p></div></div>
  <div class="gw-step"><div><h4>Food crisis</h4><p>“I have no food and no money for food until my next benefit.” Pre-apply online first if you can — it speeds the phone call. And in parallel, use the food bank (they exist for exactly this, no shame in it): emergency benefits and food banks together bridge most gaps.</p></div></div>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">If you are not currently on Income Support</h3>
<p class="leading-relaxed mb-4">The emergency stream still applies — you do not need to be an existing client. The 24-hour centre assesses food, transportation, temporary shelter, medication and medical supplies for any Albertan in a qualifying one-month crisis who meets Income Support eligibility rules. That working poor with a broken car and no food this week? Eligible to apply. The system&rsquo;s own front door is open at 3 am; most people simply do not know the number.</p>

<div class="gw gw-callout" role="note">
  <div class="gw-callout-tag">After the emergency</div>
  <p>Emergency benefits solve the acute moment, not the month. Follow up: if the crisis revealed an ongoing gap (rent above the cap, a diet need, a medical condition affecting work), file for the regular supplemental benefits — special diets, shelter top-ups, BFE status — within the week, while the documentation is fresh. And log the emergency in your journal: patterns of emergencies are evidence in future appeals that the base rate is insufficient.</p>
</div>',
  false, '2026-07-08', '8 min read'
);

-- ============================================================
-- (8) FORUM REVAMP — update existing threads, add new ones,
--     varied authors, specific facts, backdated activity.
--     Author names intentionally do not require profile rows.
-- ============================================================

-- Existing thread 1 (ADAP) — sharpen with real numbers and date fixes
update public.threads set
  title = 'ADAP transition: the $200 cliff is now on the calendar. December 31, 2027.',
  content = 'Got my transition letter in May. As of July I am in ADAP at $1,740 with a $200 transition benefit keeping me at the AISH rate — until December 31, 2027. Then it drops to $1,740 for real. That is $2,400 a year out of the pockets of people who cannot work, while the province advertises ADAP as paying "$300 more than most disability programs in Canada."

The part almost nobody is talking about: if your condition means you are PERMANENTLY unable to work, you can apply for an AISH assessment — and the government pays for one medical assessment for that purpose, any time, no deadline. But the file has to be built like an appeal: specialist letters, functional limits in writing, the panel report. If we all wait until fall 2027 to start, the files will be garbage and the cut will sail through.

Has anyone requested their medical file yet? Anyone applied for the AISH assessment? What did they ask for?',
  created_at = now() - interval '5 days'
where id = 1;

-- Existing thread 2 (IS wait times) — sharpen with the emergency stream facts
update public.threads set
  title = 'Income Support took 5 weeks. The emergency line took 20 minutes. Use both.',
  content = 'Five weeks waiting on a regular Income Support application. Rent was due. I was eating rice. Someone finally told me about the 24-hour Income Support Contact Centre — 1-866-644-5135 — and I got an emergency food benefit assessed the same night, by phone. They can even e-Transfer it now through MyAlberta Emergency Benefits if you pre-apply online first.

Things I learned the hard way:
1. The regular line (1-877-644-9992) opens at 7:30 am. Call AT 7:30. Ninety-minute holds at 10 am are eight-minute holds at 7:31.
2. "Emergency" has a legal definition (unforeseeable, severe health risk, cannot wait). Eviction notices and disconnection notices both qualify. Say the word "eviction" first sentence.
3. Upload every document AT ONCE. Partial submissions restart the clock every time.
4. Get your BFE assessment if you have ANY medical condition. The caseworker will not offer it. Ask in writing.

Five weeks to process a file is a policy choice. The emergency line existing at all is proof they know what the wait does to people.',
  created_at = now() - interval '8 days'
where id = 2;

-- Existing thread 3 (AISH denial) — sharpen with the appeal process reality
update public.threads set
  title = 'Denied by the medical panel after 7 months. Here is what I wish I knew on day one.',
  content = 'Seven months from application to denial. The medical panel said my evidence did not establish a severe handicap that permanently prevents employment — their words, and I have read them forty times.

What I did not know when I applied: the medical report my own family doctor wrote was three vague sentences. Three. The panel read "patient has chronic pain, tries his best" and said no. Nobody told me the letter needed functional limits in specific language, specialist corroboration, or a journal of daily failures.

Now I am building the appeal properly: FOIP request for the full file including the panel report (free, 30-day legal deadline), occupational therapist functional assessment booked, psychiatrist letter requested (14-month waitlist, and the wait itself is evidence). The 30-day appeal clock is running but the Notice of Appeal has a time-extension section if the evidence is not ready.

If you are applying right now: do not let your doctor write a letter. Make them complete the actual AISH medical form, address the "permanently unable to work" standard directly, and attach the specialist letters BEFORE you submit. The first application is the cheapest appeal you will ever win.',
  created_at = now() - interval '13 days'
where id = 3;

-- Existing thread 4 (AAHB dental) — sharpen with the real coverage facts
update public.threads set
  title = 'AAHB dental: what is actually covered, what needs an exception, and the CDCP stack',
  content = 'After two years of fighting tooth by tooth (pun intended), here is the real map of AAHB dental as of 2026:

COVERED WITHOUT FIGHTING: exams, x-rays, cleanings, basic fillings, extractions, dentures with prior approval. The extraction thing is real — they will pull a tooth far more readily than save it, because pulling is cheaper. Get the filling BEFORE it becomes an extraction.

NEEDS PREDETERMINATION (submit the treatment plan BEFORE booking): root canals on front teeth usually approvable; molars are the fight. Crowns basically always need the Health Benefits Exception Committee with a clinical justification letter — "two failed root canals, extraction would destabilize the bridge" wins; "patient wants crown" loses.

THE MOVE NOBODY KNOWS: if you qualify for the federal Canadian Dental Care Plan (65+, or other criteria), AAHB coordinates with it — CDCP pays first, AAHB covers the remainder. Double coverage.

And the magic phrase for your dentist: "please submit for predetermination." If the front desk says AAHB does not cover it, ask what their submission got back. Half the time nobody submits at all.',
  created_at = now() - interval '17 days'
where id = 4;

-- Existing thread 5 (6-month cap) — sharpen with Budget 2026 facts
update public.threads set
  title = 'The 6-month cap: what Budget 2026 actually says and what your appeal rights are',
  content = 'Reading the actual Budget 2026 materials so you do not have to. The cap applies to Expected-to-Work clients "not meeting program expectations" — maximum six months of benefits. What counts as "meeting expectations" is where the fight lives: job search logs, attendance at employment services appointments, participation requirements.

Your protections when a cap notice arrives:
1. They must give written notice before cutting you off — read it for what they claim you failed to do.
2. You have 30 days to appeal to the Citizens'' Appeal Panel (IES appeal form, Appeals Secretariat). Panels hear these and clients DO win when the expectations were unclear or the appointments conflicted with work/health.
3. Medical condition? BFE assessment now. BFE clients are not subject to the same cap enforcement, and the rate is higher. One doctor''s letter changes everything.
4. Every conversation with the caseworker gets documented after the fact: date, time, name, what was said. The appeal panel reads your journal and their notes side by side.

Nobody is powerless here. The cap counts on people not appealing. Be the person who appeals.',
  created_at = now() - interval '21 days'
where id = 5;

-- Existing thread 6 (AISH application guide) — sharpen
update public.threads set
  title = 'Applying for AISH/ADAP: the file that gets approved on the first try (yes, it happens)',
  content = 'Applications get denied for weak files, not weak cases. Here is the anatomy of the file that got approved for my client in 11 weeks (I volunteer helping people fill these out — 30 years as an RN taught me how panels read):

1. The AISH medical form completed by your doctor — NOT a letter. The form asks exactly what panels score: diagnosis, severity, permanence, functional limits. Make the doctor address the standard "severe handicap that permanently prevents any employment" in those words or close.
2. Specialist letters for every specialist you see. Panels weight psychiatrists, neurologists, rheumatologists far above family doctors. Waitlisted? Document the referral date — a 14-month psychiatry waitlist is itself evidence.
3. Financial eligibility is separate: assets limits, RRSP exemptions ($5,000-ish), vehicle equity caps. Spend-down advice is legal and real — ask a community legal clinic BEFORE spending anything.
4. One application covers both AISH and ADAP now. An adjudicator decides which program fits. Permanently unable to work = AISH track. Able to work with severe restrictions = ADAP track. You can apply for an AISH assessment later if your condition worsens.
5. Keep a copy of EVERYTHING. The day your file goes in, start a journal: every call, every letter, every date. If this gets denied, your appeal starts from this journal, not from scratch.

The application takes an afternoon if your documents are gathered first. The waiting takes months. The denial rate is survivable — the unprepared file rate is what kills people.',
  created_at = now() - interval '26 days'
where id = 6;

-- (9) EXISTING REPLIES — richer, varied authors, backdated
update public.replies set
  author_name = 'yeg_streetnurse',
  content = 'This is exactly right, and I want to underline the AISH assessment piece: the one paid medical assessment for transitioning clients has NO deadline. "This support is not time-limited and will be available whenever clients choose to access it" — straight from the program. The trap is psychological, not procedural. People burn out, stop fighting, and December 2027 arrives. Build the file now while you have the energy, rest, then resume.',
  created_at = now() - interval '4 days'
where id = 1;

update public.replies set
  author_name = 'coldlake_maria',
  content = 'The 7:30 am call trick saved my sanity. Also: when they ask you to "send in" documents, ask WHERE and get a reference number. I faxed my rent receipt twice and it vanished both times until I had a confirmation number to point at. And keep the emergency line number saved in your phone BEFORE you need it — at 2 am with a dead fridge you will not be looking it up. 1-866-644-5135. Save it right now.',
  created_at = now() - interval '7 days'
where id = 2;

insert into public.replies (thread_id, author_name, content, created_at) values
  (2, 'fortmac_tradeswife', 'Adding one: the e-Transfer food benefit is REAL and fast. Pre-applied online at MyAlberta Emergency Benefits at 9 pm, called the 24h line, assessment done, money next morning. When your application is in the regular queue for weeks, do not be proud — run both streams at once.', now() - interval '6 days'),
  (3, 'reddeer_renn', 'Third application was the charm for me — two denials before it. The thing that changed everything was an occupational therapist functional assessment. Panels can argue with a pain scale; it is much harder to argue with "cannot stand longer than 12 minutes, requires seated rest breaks every 20, unable to complete a mock work day." Ask your AISH worker if a functional assessment can be ordered, or get one through a community clinic. It cost me nothing and it was the single most persuasive document in the file.', now() - interval '11 days'),
  (3, 'dysthemix', 'The FOIP request is the piece most people skip and it is free for your own records: alberta.ca/access-to-information-requests, addressed to the ministry. You get the full panel report, the worker notes, everything. The 30-day response clock is legally binding, and if they blow it you complain to the OIPC for free. Full walkthrough is the "Your File Is a Weapon" guide on the blog. Read the panel''s actual words before you write a single line of your appeal.', now() - interval '10 days'),
  (4, 'lethbridge_grace', 'One more from the senior side: the Canadian Dental Care Plan enrollment is worth doing even if you think AAHB covers you. The coordination rules (CDCP first, AAHB second) mean more of the major work gets approved. My crown went from automatic denial to approved split across the two plans. Also ask your dental office to bill Alberta Blue Cross DIRECTLY — do not pay and seek reimbursement; you do not have the float.', now() - interval '15 days'),
  (5, 'coldlake_maria', 'Document everything starting NOW, before any cap notice. I keep a dated journal of every appointment conflict (childcare, health), every job application, every phone call. When the cap letter came, my journal contradicted two of their three "expectations" claims and the appeal panel sided with me. The Case Power Desk on this site has the journal built in — use it from day one, not when the letter arrives.', now() - interval '19 days'),
  (6, 'medicinehat_jay', 'On the financial side: do not panic-spend assets before talking to someone. The exemptions are real (RRSPs up to ~$5,000, vehicle equity, some prepaid funeral funds). I nearly emptied an RRSP I did not have to touch. Community legal clinics review your assets for free BEFORE you torch your savings. One appointment saved me four figures.', now() - interval '24 days'),
  (6, 'reddeer_renn', 'The "one application, two programs" thing is new and important: you do NOT choose AISH vs ADAP on the form. You describe your functional limits honestly and an adjudicator streams you. If you read the form trying to "aim" for one program you will write yourself into corners. Describe what you actually cannot do, in functional terms, every time. The programs sort themselves.', now() - interval '23 days');

-- (10) NEW THREADS — the wider lived experience of the system
insert into public.threads (id, title, category, author_name, content, created_at) values
  (7, 'Won my overpayment appeal: the calculation sheet was wrong by $1,340', 'appeals', 'fortmac_tradeswife',
   'They sent a letter saying I owed $2,890 from "unreported income" from 14 months ago. I had reported every shift. Filed the appeal (30-day deadline), requested the calculation sheet and my file. Their own math had double-counted two paycheques — the same deposit appearing in two different months. Panel erased $1,340 on the spot and set the rest at $15/month recovery instead of the default clawback.

What won it: the appeal form has a box for "why you disagree" — I wrote one sentence: "I request the complete calculation sheet for the disputed period." They are required to show their math. Their math was wrong. Almost nobody asks to see it.

The overpayment defense guide on the blog walks through all four responses. Use it before you pay anyone anything.',
   now() - interval '2 days'),

  (8, 'The medical transportation trap for rural Albertans', 'general', 'coldlake_maria',
   'Living rurally means every specialist appointment is a 300 km round trip. Income Support has transportation benefits for medical travel, but nobody explains them upfront: you need the appointment confirmation, you submit the actual costs, and there are forms. I lost probably $2,000 in unreimbursed travel over two years before another recipient mentioned it.

Also — some appointments qualify for advance funding if you cannot front the gas money. Ask BEFORE the trip, not after. And if your appointments are frequent (dialysis, oncology, psych), ask about a standing arrangement instead of filing trip by trip.

Rural recipients: what has worked for you? Different regions seem to administer this completely differently.',
   now() - interval '4 days'),

  (9, 'Roommates, cohabitation, and the benefit cut math nobody explains', 'adap', 'medicinehat_jay',
   'Starting August 2026, couples where BOTH adults receive disability assistance each get 88% of the individual rate — down from nearly the full rate. That is a couple going from roughly $3,760 combined to about $3,062. Meanwhile a random roommate has zero effect on your rate because they are not "financially interdependent."

The definitions matter enormously: the province looks at shared expenses, shared finances, presenting as a couple. Two disabled friends splitting rent are NOT automatically a couple for benefit purposes — but the forms ask questions that can trip you into being assessed as one. Answer the household questions precisely: roommates share rent, not finances. Keep separate food, separate accounts, and a written rent split. The guide on the blog has the full earnings tables too ($1,500/month exemption for cohabiting partners if you DO end up assessed as a couple — which is actually higher than the single $700).

Know which category you are in. It changes your money by hundreds a month.',
   now() - interval '6 days'),

  (10, 'What the StatsCan poverty line actually is, vs what we get paid', 'general', 'dysthemix',
   'Running the numbers for an upcoming post and wanted the community''s eyes on my math.

The Market Basket Measure poverty line for a single person in Alberta hovers around $27,000-28,000/year depending on the community. AISH at $1,940/month gross is $23,280 — below the poverty line by about $4,000-5,000 a year. ADAP at $1,740 is $20,880 — below by $6,000-7,000. Income Support ETW at ~$818/month is $9,816 — barely above HALF the poverty line.

We argue these cuts in the language of cruelty, and we are right. But the numbers win the argument with people who do not feel the cruelty: the province''s own published rates versus the federal government''s own poverty line. No adjectives needed. Just two columns.

Does anyone have regional MBM numbers handy for smaller centres (Cold Lake, Medicine Hat, Lethbridge)? The MBM varies by community size and I want the table complete.',
   now() - interval '9 days'),

  (11, 'Success thread: things that actually worked in 2026', 'general', 'yeg_streetnurse',
   'From my last six months volunteering at the forms clinic — the plays that keep working:

1. The 7:30 am call. Still true. Still the shortest holds of the day.
2. "I am requesting that in writing" — said calmly, after ANY phone decision. Changes worker behaviour instantly.
3. The Emergency Needs Allowance with the word "eviction" in the first sentence. Fast-tracks every time.
4. Predetermination BEFORE dental work. Zero exceptions. The pre-approval rate for basics is high; the after-the-fact rate is near zero.
5. The BFE assessment phrase: "I am requesting a Barriers to Full Employment assessment because my medical conditions affect my ability to work." Exactly that sentence, to your caseworker, and follow up in writing.
6. FOIP your file before every appeal. Free. 30-day legal clock. Changes everything about what you can argue.
7. The CPP-D medical report is billed to Service Canada — clinics that refuse forms usually do not know this. Tell them.

Add yours. Let''s make this the pinned thread of actual working knowledge.',
   now() - interval '11 days'),

  (12, 'AISH assessment asked me to travel 400 km for a panel medical. Now what?', 'aish', 'reddeer_renn',
   'Received a request for an in-person medical assessment related to my AISH application. The nearest panel-accepted assessor is in Edmonton. I do not drive. Greyhound is gone. The medical transportation benefit is for treatment, not assessments — catch-22.

Options I have found so far: request a reassessment for a closer assessor (in writing), ask if the assessment can be done by the assessor reviewing existing medical evidence without an in-person, or ask the program to cover travel as a disability-related employment support.

Anyone dealt with this? The letter gives 30 days and I want to respond with the right ask, not all three at once.',
   now() - interval '14 days'),

  (13, 'The shelter cap vs reality: post your rent vs your shelter benefit', 'incomesupport', 'lethbridge_grace',
   'Starting a data thread. Post: your city, your actual rent, your shelter benefit portion. I will compile.

Me first: Lethbridge, $975 all-in for a modest 1-bed, $303 shelter benefit. Gap: $672, which comes out of the basic allowance, which comes out of the food budget, which is why the food bank knows my name.

The point: a real table of real numbers, community by community, is the most shareable artifact this community can produce. Screenshots of this thread travel further than any policy paper. No addresses, no landlord names — just city, rent, benefit.',
   now() - interval '18 days'),

  (14, 'CPP-D approved after 8 months — ask me anything about the process', 'general', 'medicinehat_jay',
   'Approved last week. Eight months start to finish, denied at first application, won at reconsideration without a tribunal hearing.

Timeline: applied online March 2026 with my GP''s report (billed to Service Canada — told the clinic, they did not know), denied August with the standard "insufficient evidence of prolonged incapacity," reconsideration request September with a psychiatrist letter added and the functional impacts spelled out, approved this month.

The reconsideration letter was three pages: addressed EVERY reason from the denial letter point by point, added the psychiatrist''s functional language, and cited my own treatment history dates. No lawyer, no paid service. The denial letter literally hands you the map — answer each point, add new evidence, resubmit.

Happy to answer process questions. The forum''s federal benefits guide covers the amounts; this thread is for the how.',
   now() - interval '22 days');

-- (11) NEW REPLIES on the new threads — realistic cadence, later timestamps
insert into public.replies (thread_id, author_name, content, created_at) values
  (7, 'dysthemix', 'This is the playbook in miniature. "I request the complete calculation sheet for the disputed period" — one sentence, legally grounded, and it flips the burden. Everyone facing an overpayment letter: you have 30 days and a form. The debt is a claim, not a fact, until they show the math.', now() - interval '1 day'),
  (7, 'coldlake_maria', 'Did the same thing two years ago — their sheet had me "overpaid" shelter for months I was literally homeless and receiving zero shelter benefit. Panel zeroed the whole thing. Filing the appeal also paused the clawback while it was live. Never pay a cent before seeing the calculation sheet.', now() - interval '1 day'),
  (9, 'coldlake_maria', 'Also worth knowing: the couple rate change has an exception list. If one partner is on AISH and one is on Income Support (different programs), the interaction is different again. The benefit estimator on alberta.ca now models some of this — put your real numbers in and screenshot the result the day you get it. Statements change quietly.', now() - interval '4 days'),
  (9, 'lethbridge_grace', 'The written rent-split advice is underrated. My housing body asked for proof of expense-sharing when I had a roommate. A one-page signed agreement (rent split, who pays what utilities) made the whole assessment go smoothly. Boring paper wins boring victories.', now() - interval '3 days'),
  (10, 'yeg_streetnurse', 'Your two-column framing is exactly what works at town halls and with MLAs'' staff. One addition: theMBM numbers are published by region — Statistics Canada table 11-10-0066 — and the smaller-community MBMs are actually LOWER than Calgary/Edmonton, which still leaves every Alberta benefit below the line everywhere in the province. The argument survives its strongest counterexample.', now() - interval '7 days'),
  (10, 'fortmac_tradeswife', 'Fort Mac context: MBM for our zone runs higher because of shelter costs, and our actual rents are brutal. A $1,940 AISH cheque here is deeper below the line than the provincial average suggests. The regional table will make this impossible to wave away.', now() - interval '6 days'),
  (11, 'coldlake_maria', 'Number 2 should be carved in stone. Every single time: "Could you note that in my file, and could I have that decision in writing?" Polite, procedural, and it ends the "well I was told" disputes forever.', now() - interval '9 days'),
  (11, 'reddeer_renn', 'Adding an 8th: the AISH medical form is billed like any medical service — but some clinics still balk. The AISH program reimburses completed AISH medical reports directly (the billing info is on the form itself). If a receptionist says the doctor "does not do AISH forms," ask them to check the fee schedule on page one. Nine times out of ten the form gets done the same week.', now() - interval '8 days'),
  (12, 'yeg_streetnurse', 'From the clinic side: we have seen assessments done by the assessor reviewing the existing medical file when travel was impossible — but it was granted because the request was specific and early. "I request the assessment be completed by file review given the distance barrier and my mobility restrictions, per the program''s accommodation practices" — in writing, in week one, with your mobility documented. Also CC your MLA''s office on the second letter if the first stalls; assessments are exactly the kind of file a constituency office can move.', now() - interval '12 days'),
  (13, 'medicinehat_jay', 'Medicine Hat: $850 for a basement suite (shared utilities), $303 shelter benefit. Gap $547.', now() - interval '16 days'),
  (13, 'yeg_streetnurse', 'Edmonton: $1,150 for a decent 1-bed in a not-fancy neighbourhood, $339 shelter cap. Gap $811. And that is the CHEAP end of the market right now.', now() - interval '15 days'),
  (13, 'fortmac_tradeswife', 'Fort McMurray: $1,600 for a 1-bed, anything decent is $1,800+. Shelter benefit $339. Gap $1,261. The gap IS the homelessness pipeline.', now() - interval '14 days'),
  (14, 'reddeer_renn', 'Congratulations. And your timeline matches mine almost exactly — the "insufficient evidence of prolonged incapacity" denial is nearly universal on first application. Reconsideration with ADDED evidence is the path. One thing I tell people: the reconsideration reviewers are different adjudicators. Write the letter as if the first reviewer never read your file, because functionally they did not.', now() - interval '20 days'),
  (14, 'dysthemix', 'Pinning context: CPP-D reconsideration = 90 days from the denial letter, free, and the Social Security Tribunal after that is still free. The average new recipient cheque is $1,191.72 — more than the AISH living allowance — and it tops up rather than replaces. This thread and the federal stack guide together are the best money-per-hour of reading on this site.', now() - interval '19 days');

-- Keep id sequences ahead of the explicit ids used above.
select setval(pg_get_serial_sequence('public.threads','id'), (select coalesce(max(id),1) from public.threads));
select setval(pg_get_serial_sequence('public.replies','id'), (select coalesce(max(id),1) from public.replies));

-- (12) Late-bound rewrites of the two legacy posts (title-based updates ran after inserts)
update public.blog_posts set
  title = 'ADAP Is Live: The Real Numbers, Who Keeps What, and the December 2027 Cliff',
  category = 'Disability Benefits',
  excerpt = 'The July 2026 transition moved thousands of Albertans off AISH. Here is exactly what changed, what the $200 transition benefit really does, and the deadline math nobody is putting on a fridge magnet.',
  read_time = '12 min read',
  published_at = '2026-09-02',
  content = '<p class="text-lg leading-relaxed mb-6">On July 1, 2026, Alberta began moving disability clients into the <strong>Alberta Disability Assistance Program</strong>. The government calls it modernization. The people living on it call the core number what it is: $1,740 a month, down from $1,940 — a <strong>10.3% cut</strong> papered over with a temporary top-up that dies on December 31, 2027. This guide separates what the program actually says from what it actually means, with every number sourced from alberta.ca.</p>

<div class="gw gw-stats" aria-label="Key ADAP numbers">
  <div class="gw-stat"><div class="gw-stat-value" data-count="1740" data-prefix="$">$1,740</div><div class="gw-stat-label">ADAP core, per month</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="1940" data-prefix="$">$1,940</div><div class="gw-stat-label">AISH living allowance</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="200" data-prefix="−$">−$200</div><div class="gw-stat-label">Monthly cut after Dec 2027</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="2400" data-prefix="$">$2,400</div><div class="gw-stat-label">Lost per year, per person</div></div>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">Who was automatically kept on AISH</h3>
<p class="leading-relaxed mb-4">Not everyone moved. Per the official transition criteria, these groups stayed on AISH unless they chose to leave:</p>
<ul class="space-y-3 mb-6">
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span>People with a <strong>severe or profound developmental disability</strong>, or receiving PDD services</span></li>
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span>People with <strong>palliative or terminal</strong> conditions</span></li>
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span>People living in <strong>continuing care homes</strong></span></li>
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span>People <strong>60 or older</strong></span></li>
</ul>
<p class="leading-relaxed mb-4">Everyone else transitioned. If your condition means you are now permanently unable to work, you can <strong>apply for an AISH assessment</strong> — and the province covers the cost of one medical assessment for that purpose, any time, with no deadline.</p>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">The earnings tables, decoded</h3>
<p class="leading-relaxed mb-4">The real trade is on employment income. ADAP lets you earn far more before benefits taper:</p>
<div class="gw gw-bars" aria-label="Earnings exemption comparison">
  <div class="gw-bars-title">Monthly earnings before benefits are affected — AISH vs ADAP (2026)</div>
  <div class="gw-bar-row"><div class="gw-bar-head"><span>AISH single or parent</span><strong>$350</strong></div><div class="gw-bar-track"><div class="gw-bar-fill g-blue" style="--w:.31"></div></div></div>
  <div class="gw-bar-row"><div class="gw-bar-head"><span>ADAP single</span><strong>$700</strong></div><div class="gw-bar-track"><div class="gw-bar-fill g-gold" style="--w:.62"></div></div></div>
  <div class="gw-bar-row"><div class="gw-bar-head"><span>ADAP parent with children</span><strong>$1,100</strong></div><div class="gw-bar-track"><div class="gw-bar-fill g-gold" style="--w:.97"></div></div></div>
  <div class="gw-bar-row"><div class="gw-bar-head"><span>AISH or ADAP cohabiting partner</span><strong>$1,500</strong></div><div class="gw-bar-track"><div class="gw-bar-fill g-blue" style="--w:1"></div></div></div>
</div>
<p class="leading-relaxed mt-4 mb-4">ADAP singles can earn up to <strong>$700/month</strong> with zero clawback, tapering slowly after — the province advertises earnings up to <strong>$45,240 per year</strong> while keeping some benefit, the highest ceiling in Canada. If you can work episodically, that is real money. If you cannot — and most people moved into ADAP cannot — it is a marketing line wrapped around a $200 monthly pay cut.</p>

<div class="gw gw-callout c-red" role="note">
  <div class="gw-callout-tag">The December 2027 cliff</div>
  <p>The $200 monthly transition benefit runs to <strong>December 31, 2027</strong>. On January 1, 2028, every transitioned client drops to $1,740 unless they have won an AISH assessment in the meantime. That is roughly 16 months to build medical files strong enough to qualify under the old standard. Start now: request your full file, line up specialist letters, document functional limits in writing. The system is in our <strong>AISH Appeal Bible</strong> guide.</p>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">What did not change (and two things that got worse)</h3>
<ul class="space-y-3 mb-6">
  <li class="flex gap-3"><span class="font-bold" style="color:var(--blue)">✓</span><span><strong>Health benefits continue</strong> — dental, optical, drugs — regardless of employment income. The genuinely good part of ADAP.</span></li>
  <li class="flex gap-3"><span class="font-bold" style="color:var(--blue)">✓</span><span><strong>Personal benefits survive</strong> — special diets, emergency allowances, the personal-benefits catalogue.</span></li>
  <li class="flex gap-3"><span class="font-bold" style="color:var(--red)">✗</span><span><strong>Medical panel decisions are final.</strong> A Medical Review Panel denial of AISH medical eligibility cannot be appealed to the Citizens&rsquo; Appeal Panel. Only judicial review or the Alberta Ombudsman remain — which makes the initial application the most important document you will ever file.</span></li>
  <li class="flex gap-3"><span class="font-bold" style="color:var(--red)">✗</span><span><strong>Couples take a new cut.</strong> Starting August 2026, where both adults in a household receive disability assistance, each partner receives <strong>88% of the individual maximum</strong>. About 7,000 households affected.</span></li>
  <li class="flex gap-3"><span class="font-bold" style="color:var(--red)">✗</span><span><strong>The CDB clawback stands.</strong> Alberta deducts the federal $200/month Canada Disability Benefit dollar-for-dollar. Apply anyway — other programs key off it, and the fall 2026 $150 supplement still pays.</span></li>
</ul>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">Your transition checklist</h3>
<div class="gw gw-steps" aria-label="Immediate action steps">
  <div class="gw-step"><div><h4>Read your transition letter line by line</h4><p>It states your stream and your numbers. Every dispute starts from this document. Lost it? Your AISH/ADAP office resends — get it in writing.</p></div></div>
  <div class="gw-step"><div><h4>Check your August statement against the tables</h4><p>Couples: verify the 88% math. Workers: verify the $700 exemption. Benefit errors cluster at transition moments — the government&rsquo;s own site directs clients to the benefit estimator because payment changes are expected.</p></div></div>
  <div class="gw-step"><div><h4>Apply for the Canada Disability Benefit anyway</h4><p>$200/month federal, paid the third Thursday. Alberta claws it back — but a CDB approval locks in eligibility for the future and the one-time $150 supplement. File it.</p></div></div>
  <div class="gw-step"><div><h4>Calendar December 31, 2027</h4><p>The day the transition benefit dies. An AISH assessment, if you want one, needs filing well before — files built in a panic in late 2027 are the weakest ones.</p></div></div>
</div>

<div class="gw gw-callout" role="note" style="margin-top:2.5rem">
  <div class="gw-callout-tag">Who to call</div>
  <p><strong>Alberta Supports:</strong> 1-877-644-9992 (Mon–Fri 7:30–8). <strong>24-hour emergency line:</strong> 1-866-644-5135. <strong>Appeals Secretariat:</strong> 780-427-2709 (Edmonton) / 403-297-5636 (Calgary). <strong>Alberta Ombudsman:</strong> 1-888-455-2756 — the external review left for medical-panel decisions.</p>
</div>'
where title = 'AISH to ADAP: What the July 2026 Transition Means for You';
update public.blog_posts set
  title = 'The AISH Appeal Bible: A File-Building System That Wins',
  category = 'Appeals',
  excerpt = 'Thirty days, one binder, five evidence streams. The complete system for appealing an AISH denial — built from the Appeals Secretariat''s own rules and the mistakes that sink most appeals.',
  read_time = '15 min read',
  published_at = '2026-08-19',
  content = '<p class="text-lg leading-relaxed mb-6">A denial letter is not a verdict. It is an opening offer. Under the <em>Assured Income for the Severely Handicapped Act</em>, you can appeal most AISH decisions to the Citizens&rsquo; Appeal Panel — an independent, free hearing with community members on it, not government staff. Most people lose not because their case is weak, but because their file is. This is the file-building system.</p>

<div class="gw gw-deadline" role="alert">
  <div class="gw-pulse" aria-hidden="true"></div>
  <p><strong>You have 30 days from the day you received the decision.</strong> Not the decision date — when it hit your hands. If the 30 days are gone, the AISH Act (s. 10(4)) lets the minister extend the deadline for a reasonable excuse, and the Notice of Appeal form has a section for exactly this request. Extensions are decided by the minister&rsquo;s delegate at the Appeals Secretariat, in writing.</p>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">First, know what you are appealing</h3>
<p class="leading-relaxed mb-4">Your denial letter must tell you whether you failed <strong>medical eligibility</strong> (severity/permanence) or <strong>financial eligibility</strong> (income/assets). The evidence that wins is completely different:</p>
<div class="gw gw-table-wrap"><table class="gw-table">
  <thead><tr><th>Denial basis</th><th>What wins</th><th>Time to gather</th></tr></thead>
  <tbody>
    <tr><td class="font-semibold">Medical</td><td>Specialist letters using program language, functional assessments, daily-impact evidence</td><td>3–8 weeks — start immediately</td></tr>
    <tr><td class="font-semibold">Financial</td><td>Bank statements, CRA notices of assessment, proof assets are spent/exempt</td><td>1–2 weeks</td></tr>
    <tr><td class="font-semibold">Rate/benefit cut</td><td>Payment statements, the policy citation they relied on, your calculation</td><td>Days</td></tr>
  </tbody>
</table></div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">Step one: get the file (this is your case now)</h3>
<p class="leading-relaxed mb-4">Before anything else, request <strong>everything</strong>: the medical panel report and your complete application file. You have a right to see what they relied on. Two routes:</p>
<ul class="space-y-3 mb-6">
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>Ask AISH directly</strong> for your file and the panel&rsquo;s written reasons — a phone call starts it, confirmed in writing.</span></li>
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>FOIP request</strong> (free, for your own personal information) — no application fee for personal records, response due within 30 days. It reaches internal notes the casual ask never surfaces.</span></li>
</ul>
<p class="leading-relaxed mb-4">The medical panel report tells you the exact words they used to deny you. Your appeal letter must answer those exact words, one by one. This single move separates winning appeals from losing ones.</p>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">The five evidence streams</h3>
<div class="gw gw-steps" aria-label="Evidence streams">
  <div class="gw-step"><div><h4>The physician anchor letter</h4><p>Not &ldquo;my patient has X and is unable to work.&rdquo; The winning structure: diagnosis, severity, <strong>permanence in the program&rsquo;s own words</strong>, specific functional limits (cannot sit/stand more than X minutes, cannot concentrate more than X minutes), medication side effects. Our Resources page has the fill-in-the-blank letter.</p></div></div>
  <div class="gw-step"><div><h4>Specialist corroboration</h4><p>Every specialist who has seen you — panels weight them over family doctors. Wait-listed? Document the referral date; a 14-month psychiatry wait is itself evidence of severity and system failure.</p></div></div>
  <div class="gw-step"><div><h4>The functional assessment</h4><p>An occupational therapist&rsquo;s functional capacity evaluation converts diagnoses into daily-living limits. Often the single most persuasive document in a file, because it describes <em>what you cannot do</em> rather than what you have.</p></div></div>
  <div class="gw-step"><div><h4>The daily impact journal</h4><p>Three months of dated entries: what you attempted, what failed, what it cost. One month of honest entries beats any adverb in a doctor&rsquo;s letter. The Case Power Desk journal exists for exactly this.</p></div></div>
  <div class="gw-step"><div><h4>Third-party witnesses</h4><p>Former employers, caregivers, family — people who see the bad days. Short, dated, signed statements of <em>observed</em> limitations. Observation letters, not character letters.</p></div></div>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">Filing the appeal, precisely</h3>
<ul class="space-y-3 mb-6">
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>Option A:</strong> the AISH Notice of Appeal form (fillable PDF on alberta.ca), signed. Section 3 is the time-extension request if you are late.</span></li>
  <li class="flex gap-3"><span class="font-bold mt-0.5" style="color:var(--gold)">→</span><span><strong>Option B:</strong> an appeal letter — your name/address/phone, the decision appealed, the date received, the date told of the 30-day right, why you are appealing, signature. Add the Authorization form if someone is helping.</span></li>
</ul>
<div class="gw gw-callout c-blue" role="note">
  <div class="gw-callout-tag">Where it goes</div>
  <p>Email: <strong>ALSS.Appeals@gov.ab.ca</strong>. Phone: <strong>780-427-2709</strong> (Edmonton), <strong>403-297-5636</strong> (Calgary), <strong>403-340-5531</strong> (Red Deer), <strong>403-381-5681</strong> (Lethbridge). Fax: 780-422-1088. Keep copies and the acknowledgement letter.</p>
</div>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">After filing: the quiet settlement window</h3>
<p class="leading-relaxed mb-4">The government&rsquo;s own page admits it: after you file, <strong>the AISH program reviews the decision to see if it can be resolved without a hearing</strong>. New evidence arriving at exactly this moment sometimes flips the decision outright — keep gathering even after filing. If it resolves, withdraw; if not, the hearing is scheduled and you get the program&rsquo;s disclosure package at least a week before.</p>

<h3 class="text-2xl font-heading font-bold mt-12 mb-4">The hearing itself</h3>
<p class="leading-relaxed mb-4">The Citizens&rsquo; Appeal Panel is informal: usually three community members, an advocate or supporter at your side, your story told in your words. Bring your binder (originals plus copies), your witness list, your one-page summary of what the decision got wrong. <strong>Voice of Albertans with Disabilities</strong>, <strong>Disability Action Hall</strong> (Calgary), and <strong>Calgary Legal Guidance</strong>&rsquo;s free AISH self-representation guidebook all help.</p>

<div class="gw gw-callout c-red" role="note">
  <div class="gw-callout-tag">The ADAP-era warning</div>
  <p>Under the 2026 changes, <strong>Medical Review Panel decisions on AISH medical eligibility are final and cannot be appealed</strong> to the CAP. What remains: appeal financial decisions normally, complain to the <strong>Alberta Ombudsman</strong> (1-888-455-2756, free), or judicial review in King&rsquo;s Bench (Legal Aid Alberta covers some). If your denial came through the new medical panel process, the Ombudsman is now the external check — use it, precisely and factually.</p>
</div>

<div class="gw gw-stats" aria-label="Appeal basics" style="margin-top:2.5rem">
  <div class="gw-stat"><div class="gw-stat-value" data-count="30" data-suffix=" days">30 days</div><div class="gw-stat-label">Filing deadline</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="5">5 streams</div><div class="gw-stat-label">Evidence that wins</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="0" data-prefix="$">$0</div><div class="gw-stat-label">Cost to appeal</div></div>
  <div class="gw-stat"><div class="gw-stat-value" data-count="1" data-suffix=" file">1 file</div><div class="gw-stat-label">Everything, in one binder</div></div>
</div>'
where title = 'AISH Denied? Here''s Your Appeal Strategy';
