# Daily Security Scan — 2026-07-07

## Scope & Baseline

First run of this automated daily security-scan routine — no prior `security-scan-*.md` exists. Used the most recent existing repo audit (`reports/audit-2026-06-30.md`) as the reference point for "since the last scan" and checked each in-scope repo's latest commit date against it.

**Repos in scope (15 total):**

| Repo | Last commit | Since baseline (2026-06-30)? |
|---|---|---|
| neo-control | 2026-07-06 | ✅ Updated |
| dotfiles | 2026-07-02 | ✅ Updated |
| where-it-counts | 2026-07-01 | ✅ Updated |
| true-cost-of-car-ownership | 2026-06-30 | ✅ Updated (on boundary) |
| amanda-repository | 2026-06-18 | No change |
| Calculator2.0 | 2026-06-18 | No change |
| screenprops | 2026-06-13 | No change |
| amandarae220 | 2026-05-29 | No change |
| doteon | 2026-05-29 | No change |
| scamlessgames | 2026-05-23 | No change |
| tamagotchi-game | 2026-04-22 | No change |
| DungeonsAndDragons | 2025-12-05 | No change |
| sudoku | 2025-02-17 | No change |
| interactiveResume | 2024-07-28 | No change |
| habitTracker | 2024-03-09 | No change |

4 repos updated since baseline → scanned in depth. 11 repos unchanged → skipped detailed scanning per instructions.

---

## Executive Summary

**1 critical, 2 high, 1 medium, 2 low** findings across 4 scanned repos. The critical issue is in **neo-control**: a plaintext admin password was committed to git history and remains fully recoverable despite a later "fix" commit that only redacted it going forward. The same commit that removed that password also introduced two high-severity authorization gaps in the new Supabase-based admin login. `dotfiles` is clean. `where-it-counts` and `true-cost-of-car-ownership` each have one low-risk `{@html}`/`innerHTML` pattern worth hardening defensively, plus one medium (missing SRI on a CDN script).

---

## Findings by Severity

### 🚨 Critical

**neo-control — `CONTEXT.md` (commit `0870f3f`, "fixed" in `6819dd2`)**
Plaintext admin password `checkadmininsights` was committed as `VITE_ADMIN_PASS # currently: checkadmininsights`. A follow-up commit redacted the value in the file, but the plaintext is still fully retrievable from git history (`git log -p`) and on GitHub. The auth commit on 2026-07-06 removed `VITE_ADMIN_PASS` entirely in favor of Supabase auth, so this string is no longer the app's gate — but if it was reused as a password anywhere else, treat it as burned.
**Fix:** Rotate any account/credential that ever used this value. Scrub git history with `git filter-repo` or BFG and force-push (coordinate before doing this — rewrites history). Don't rely on a later commit to "undo" a leak.

### 🔴 High

**neo-control — `src/pages/AdminPage.tsx` (commit `ceef7ec`, "manual auth updates")**
The hardcoded passphrase gate was replaced with `supabase.auth.signInWithPassword`, but any user who can authenticate against the Supabase project — including a self-registered account — is granted `authed = true` and sees the admin analytics UI. There's no role/claim check restricting access to an actual admin.
**Fix:** Confirm sign-up is disabled on the Supabase project, or check a custom claim/role after sign-in before setting `authed`.

**neo-control — `src/lib/sessions.ts` (`fetchSessions()`) / Supabase RLS**
The real data boundary here is Supabase Row Level Security, not the UI login screen. Per the repo's own decision log, the `sessions` table already accepts anonymous public inserts and the anon key is public by design. If SELECT on `sessions` isn't restricted to an authenticated/admin role, anyone with the (public, bundle-embedded) anon key can query `supabase.from('sessions').select('*')` directly and dump all player analytics, completely bypassing the new login screen.
**Fix:** Confirm in the Supabase dashboard that `sessions` SELECT policy requires `auth.role() = 'authenticated'` or a specific admin claim, not public/anon.

### 🟡 Medium

**true-cost-of-car-ownership — `index.html:10-11`**
`chart.js@4.4.0` and `chartjs-plugin-datalabels@2.2.0` are loaded from `cdn.jsdelivr.net` without Subresource Integrity (SRI) hashes or `crossorigin` attributes. A compromised CDN or MITM could silently swap in malicious JS. No known CVEs affect the pinned versions themselves.
**Fix:** Add SRI hashes (jsDelivr provides them) and `crossorigin="anonymous"` to both `<script>` tags.

### 🟢 Low

**where-it-counts — `src/lib/components/Scrollytelling.svelte:51`**
`{@html step.text}` renders content from the hardcoded `surplusSteps` array (author-controlled, no user input or external fetch feeds it today) — minimal real risk, but a live XSS sink if this content source ever becomes dynamic or CMS-driven.
**Fix:** Use plain `{step.text}` interpolation, or sanitize if the source ever changes.

**true-cost-of-car-ownership — `index.html:2401, 2414`**
`.innerHTML =` inserts computed strings (`dep-insight`, `gap-insight`) derived entirely from numeric range-slider inputs with hardcoded min/max/step — not currently exploitable, but fragile if a text input or URL param is ever wired in upstream without sanitization.
**Fix:** Switch to `textContent` + manual DOM construction, or sanitize defensively.

**neo-control — `CONTEXT.md`**
Still documents the old auth model ("password-gated via `VITE_ADMIN_PASS`") after the switch to Supabase auth — stale and could mislead future maintainers. Doc-only, no security impact.
**Fix:** Update `CONTEXT.md` to reflect the current Supabase-based auth flow.

---

## Repos With No Issues

- **dotfiles** — full pass, no secrets, no dependency manifests (N/A), no risky shell/install-script patterns. Newest commit (`e763a29`, adding skill docs) is markdown-only.
- **where-it-counts** (aside from the one low finding above) — no committed secrets, dependencies current and patched (Vite 5.4.21, SvelteKit 2.65.0, D3 7.9.0), no server-side routes (static adapter), no CORS surface.
- **true-cost-of-car-ownership** (aside from the medium/low above) — no committed secrets, no `eval`/`document.write`, all resources loaded over HTTPS.
- **neo-control** — `npm audit`: 0 vulnerabilities. No injection/IDOR/CSRF issues found beyond the auth items above.

## Repos Skipped (No Activity Since Baseline)

amanda-repository, Calculator2.0, screenprops, amandarae220, doteon, scamlessgames, tamagotchi-game, DungeonsAndDragons, sudoku, interactiveResume, habitTracker — no commits since 2026-06-30. Not scanned this run.

---

## Top Action Items

1. **[CRITICAL — neo-control]** Rotate any credential ever set to `checkadmininsights` and scrub it from git history.
2. **[HIGH — neo-control]** Add a role/claim check to `AdminPage.tsx` so any authenticated Supabase user isn't automatically treated as admin.
3. **[HIGH — neo-control]** Verify Supabase RLS restricts `sessions` SELECT to authenticated/admin — the anon key can otherwise read all player data directly.
4. **[MEDIUM — true-cost-of-car-ownership]** Add SRI hashes to the two CDN `<script>` tags in `index.html`.
5. **[LOW — where-it-counts, true-cost-of-car-ownership]** Replace the two flagged `{@html}`/`innerHTML` usages with safer text-insertion patterns as defense-in-depth.
