# Security Scan — 2026-08-12

## Scope & Methodology

Incremental scan against the prior baseline, `reports/security-scan-2026-07-04.md` (2026-07-04). Per that report's checkpoint table, only repos with commits since their recorded checkpoint SHA were deep-scanned; repos with no new commits were skipped per the recurring-scan design.

8 of 15 repos had new commits since baseline and were reviewed in full (diff-focused: re-checking every 2026-07-04 finding for remediation status, plus scanning all changed files for newly introduced issues). 7 repos were unchanged and skipped.

## Repos Scanned — Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Status this run |
|---|---|---|---|---|
| neo-control | `97e4243` | 2026-07-08 | amandarae220 | Updated — reviewed |
| dotfiles | `9e31777` | 2026-07-30 | amandarae220 | Updated — docs/skills only, no app code |
| where-it-counts | `32084ee` | 2026-07-09 | amandarae220 | Updated — reviewed |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | amandarae220 | No new commits — skipped |
| amanda-repository | `d8e3777` | 2026-08-04 | amandarae220 | Updated — reviewed |
| Calculator2.0 | `a36134a` | 2026-07-30 | amandarae220 | Updated — reviewed |
| screenprops | `fb5662a` | 2026-07-10 | amandarae220 | Updated — reviewed |
| amandarae220 (profile) | `24d9a2c` | 2026-07-28 | amandarae220 | Updated — README text only |
| doteon | `5413b63` | 2026-05-29 | amandarae220 | No new commits — skipped |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ | No new commits — skipped |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 | No new commits — skipped |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 | No new commits — skipped |
| sudoku | `923a3c1` | 2026-08-10 | amandarae220 | Updated — reviewed |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 | No new commits — skipped |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 | No new commits — skipped |

**6 of 6 updated app-code repos reviewed.** Findings: **0 critical, 0 high, 1 medium, 5 low/informational.** All 4 critical/high findings from the 2026-07-04 baseline are confirmed remediated. No new critical or high-severity issues were introduced by any of this cycle's changes.

---

## ✅ Remediated Since Last Scan

**`neo-control` — exposed `VITE_ADMIN_PASS` credential (was critical)**
The plaintext passphrase is gone from `CONTEXT.md` and the codebase (`fa0f370c`, `ceef7ece`). `src/pages/AdminPage.tsx` was rewritten to use `supabase.auth.signInWithPassword()` with session restore/`signOut()` — a genuine move to server-side auth, not a deleted check with nothing behind it. `src/lib/supabase.ts` wires only the public `VITE_SUPABASE_URL`/anon key, no hardcoded secrets. Repo-wide search for `VITE_ADMIN_PASS` returns zero hits.

**`neo-control` — react-router-dom / vite dependency CVEs (was high)**
`ccb1e499` ("npm audit fix") bumped `react-router-dom` 7.14.2 → 7.18.1 and `vite` 8.0.9 → 8.1.3 — both past the patched releases for the previously flagged DoS/CSRF/NTLMv2 advisories. `js-yaml` and `brace-expansion` (low/informational) also bumped in the same commit.

**`Calculator2.0` — stored XSS in `admin.html` (was high)**
Fixed in `e609f4a7` (part of PR #12). The vulnerable `innerHTML` string-concat for `<option>` tags was replaced with a `populateSelect()` helper using `createElement`/`textContent`. A secondary hardening allow-lists `event_type` before it's used in a CSS `className`, closing an adjacent lower-severity injection vector. Note: the originally recommended DB-level CHECK constraint on `device`/`browser` columns was not added (still unconstrained `text` in `docs/calculator_events_schema.sql`) — not currently exploitable since the client-side sink is closed, but flagged again below as defense-in-depth.

**`sudoku` — 57 npm vulnerabilities in the CRA/`react-scripts` toolchain (was high)**
The repo migrated fully off Create React App to Vite (`55fc1ac8`, `bf9d20a7`, plus `npm audit fix` via PR #2). `react-scripts` is completely gone from `package.json`/`package-lock.json`; no CRA remnants (`craco.config.js`, etc.) remain. Current Vite is `7.3.6` — not the CVE-flagged `8.0.9` seen elsewhere in the fleet. `form-data` and `ws` are both at CVE-patched versions.

---

## 🟡 Medium

**`screenprops` — client-side-only Supabase RLS scoping on `projects` table (carried over, unresolved)**
This is a live-Supabase-dashboard configuration matter, not something a commit can fix — no RLS policy files or `supabase/migrations` exist in the repo either way, so repo state gives no new evidence. The new "pricing page" added this cycle does not touch this table or any billing/subscription data (it's a static marketing page with only an auth-status check), so no new exposure was introduced. **Action unchanged: verify RLS is enabled and correct on `projects` directly in the Supabase dashboard.**

---

## 🟢 Low / Informational

- **`amanda-repository`**: The pre-existing burned password in git history (`src/environments/environment.ts`, commit `875772e`) remains permanently retrievable via `git log --all -p`. It's inert in current code (auth moved to Supabase `signInWithPassword`) and was already flagged as an accepted risk in the 2026-07-04 report — no change, no action needed unless a history rewrite is desired.
- **`amanda-repository`**: The rehosted calculator (`public/calculator-v2/assets/config.js`) ships a second intentionally-public Supabase anon key for a separate project (`bkkcwlpkgwqobfdtcomx`), same accepted pattern as the primary key (RLS is the boundary, not key secrecy).
- **`Calculator2.0`**: CDN-loaded D3 and Supabase-js (`index.html`, `admin.html`) still have no `integrity`/SRI attributes — unresolved from the last scan.
- **`Calculator2.0`**: DB-level CHECK constraint on `device`/`browser` columns still not added (see remediation note above) — defense-in-depth gap, not currently exploitable.
- **`where-it-counts`**: `Scrollytelling.svelte:51` still uses `{@html step.text}` on hardcoded static strings. Confirmed unchanged and still not sourced from any dynamic/CMS path — latent risk only, recommendation to switch to plain interpolation still stands.

---

## Repos With No Issues Found

- **`where-it-counts`** — Svelte 4→5 / Vite 5→8 major upgrade (PR #8) landed on CVE-clean versions (`svelte` 5.56.4, `vite` 8.1.4, `@sveltejs/kit` 2.69.2); no new `{@html}` usage introduced by the migration.
- **`sudoku`** — new stats/leaderboard feature is `localStorage`-only with zero network calls; no backend attack surface. Font self-hosting swap (Fraunces/Nunito Sans, OFL-licensed) is a security/privacy improvement over the prior CDN load.
- **`amanda-repository`** — large "rehost calculator v1" feature merge introduced no new XSS, secrets, or RLS anti-patterns; the admin dashboard's prior XSS fix (see Calculator2.0 above) carried over correctly into the rehosted copy.
- **`screenprops`** — new pricing page has no checkout/payment integration wired up yet, no secrets, no user-scoped data queries.
- **`dotfiles`** — this cycle's commits were skill/report markdown only, no application code changed.
- **`amandarae220` (profile)** — README text edits only.

---

## Repos Not Updated Since Last Scan (skipped)

`true-cost-of-car-ownership`, `doteon`, `scamlessgames`, `tamagotchi-game`, `DungeonsAndDragons`, `interactiveResume`, `habitTracker` — no commits since their 2026-07-04 checkpoint SHAs. Not re-scanned per the incremental-scan design.

---

## Top Actions (ranked)

1. **Verify Supabase RLS on `screenprops`'s `projects` table directly in the Supabase dashboard** — the only open item that isn't already a fully-accepted/inert risk.
2. Optional hardening: add SRI hashes to `Calculator2.0`'s CDN `<script>` tags (D3, Supabase-js) and a DB-level CHECK constraint on the `device`/`browser` event columns.
3. Optional: `where-it-counts` — swap `{@html step.text}` for plain interpolation in `Scrollytelling.svelte` to remove the latent-XSS pattern entirely, even though it's not currently reachable.
4. No action needed on the two "burned in git history" items (`amanda-repository`) — already inert and previously accepted; only relevant if a history rewrite is ever undertaken.
