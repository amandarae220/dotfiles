# Security Scan — 2026-07-21

## Scope & Methodology

This is an incremental scan. A prior full baseline scan (`reports/security-scan-2026-07-04.md`) established a checkpoint table of last-commit SHAs for all 15 accessible repos. This run compared each repo's current HEAD against that checkpoint: **7 of 15 repos had new commits and were deep-scanned in full**; the remaining 8 were unchanged and skipped per the recurring-scan methodology (their prior findings still stand as last reported).

Each updated repo was scanned (read-only, no files modified) for: exposed secrets/credentials (tracked files + full commit range since the last checkpoint), XSS-class injection risks, dependency vulnerabilities, insecure transport, and exposed/unauthenticated API surface. Known open findings from the prior scan were explicitly re-verified against the new commits rather than re-derived from scratch.

**Note on credential handling:** the 2026-07-04 report was found to have quoted two live/burned credentials verbatim, which — because that report itself lives in this repo — leaked those values into `dotfiles`' own git history (see Critical findings below). This report does not restate any credential values, to avoid repeating that mistake.

## Repos Scanned — Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Updated this cycle? |
|---|---|---|---|---|
| neo-control | `97e4243` | 2026-07-08 | amandarae220 | ✅ yes |
| dotfiles | `1d241a6` | 2026-07-18 | amandarae220 | ✅ yes |
| where-it-counts | `32084ee` | 2026-07-09 | amandarae220 | ✅ yes |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | amandarae220 | no |
| amanda-repository | `3dddcfd` | 2026-07-09 | amandarae220 | ✅ yes |
| Calculator2.0 | `93e0ae5` | 2026-07-07 | amandarae220 | ✅ yes |
| screenprops | `fb5662a` | 2026-07-10 | amandarae220 | ✅ yes |
| amandarae220 (profile) | `2bc6ffb` | 2026-05-29 | amandarae220 | no |
| doteon | `5413b63` | 2026-05-29 | amandarae220 | no |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ | no |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 | no |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 | no |
| sudoku | `b0788f2` | 2026-07-10 | amandarae220 | ✅ yes |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 | no |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 | no |

7 of 15 repos updated and deep-scanned. Findings this cycle: **2 critical, 1 high, 2 medium, 6 low/informational.** 3 previously-open findings were resolved this cycle (see below).

---

## 🚨 Critical

**`dotfiles` — this repo's own history now contains two leaked credentials**
The 2026-07-04 scan report (commit `1a836e1`, 2026-07-04) quoted two real, plaintext credential values verbatim: neo-control's live `VITE_ADMIN_PASS` value, and amanda-repository's already-burned admin password. Commit `f59b6e6` (2026-07-07) redacted both values in the *current* file content, but git history was never rewritten — both values remain permanently retrievable via the commit's blob (`git show 1a836e1` / GitHub's API) regardless of the later redaction. The older `reports/audit-2026-06-16.md:13` independently quotes the same amanda-repository password and has the same exposure.
- **Action:** treat this as a second, independent exposure of both credentials (on top of their original home-repo exposure). If either value is reused anywhere, rotate it. Consider `git filter-repo`/BFG history rewrite for `dotfiles` if a full purge is warranted — this repo is public. Going forward, this recurring scan must never quote a live/burned credential verbatim in a committed report (this report follows that rule).

**`neo-control` — burned admin credential permanently exposed in public repo history (partially fixed)**
The code-level vulnerability from 2026-07-04 is genuinely fixed: `AdminPage.tsx` (commit `ceef7ece9`) no longer does a client-side `VITE_ADMIN_PASS` string compare — it now uses real `supabase.auth.signInWithPassword()`, with RLS as the actual guard, matching the repo's documented design. `VITE_ADMIN_PASS` has zero remaining references anywhere in the current tree.
- However, the original passphrase value itself is still permanently retrievable from this **public** repo's git history (it was committed in `CONTEXT.md` before being scrubbed in commits `6819dd2` and `fa0f370` — content-only fixes, no history rewrite).
- **Action:** treat that original passphrase as permanently burned — confirm it isn't reused as the new Supabase account's password or anywhere else. History rewrite is optional (the code fix already closes the live exploit path) but the value itself can never be treated as secret again.

## 🔴 High

- **`Calculator2.0`**: `admin.html:551-552` — the stored-XSS finding from 2026-07-04 is **still present, unaddressed**. `device`/`browser` values from the Supabase `calculator_events` table (writable by anyone via the public anon key under the `anon insert with check (true)` RLS policy) are still concatenated into `innerHTML` when populating the two filter `<option>` dropdowns in `populateDeviceAndBrowserFilters()`. The "Recent Events" feed elsewhere in the same file already uses safe `textContent`/`createElement` — only these two dropdown populators remain vulnerable. The intervening "feature/angular-makeover" PR (#11) touched only copy/CSS/a11y content and did not address this. **Fix (repeated from last cycle): replace both `innerHTML` assignments with `createElement('option')` + `textContent`, and add a `check (device in (...))` / `check (browser in (...))` constraint to `docs/calculator_events_schema.sql`.**

## 🟡 Medium

- **`screenprops`**: The `projects` table ownership-scoping issue from 2026-07-04 is **still open, unchanged**. `.eq("user_id", user.id)` in `app/dashboard/page.tsx:36` and `DashboardClient.tsx:38` remains the only enforcement, using an anon-key Supabase client with no server-side route handlers or RLS SQL/migration files anywhere in the repo. Two commits landed this cycle (a `/pricing` page, an a11y-motivated animation fix) — neither touched this. Cannot be verified as safe or unsafe from code alone. **Action: confirm RLS policies directly in the live Supabase project dashboard** — this has now been open for two consecutive scan cycles.
- **`dotfiles`**: process finding tied to the Critical item above — the fix applied to the leaked-credential report was redaction-only, not a history rewrite, which risks giving a false sense of closure in future scans. Logged explicitly here so it isn't mistaken for fully resolved.

## 🟢 Low / Informational

- **`amanda-repository`**: `package.json`'s `vitest` floor (`^4.0.8`) technically spans a range that included a since-patched critical CVE (unauthenticated Vitest UI/API-server file read/RCE, fixed in 4.1.0+). The lockfile already resolves to the patched `4.1.10`, and no script/CI workflow invokes the Vitest UI server, so there's no live exposure — but the declared floor doesn't exclude the vulnerable range. Bump the floor to `^4.1.10` for defense-in-depth.
- **`amanda-repository`**: `.github/workflows/pages.yml` uses tag-pinned (not SHA-pinned) first-party `actions/*` steps. No `pull_request`/`pull_request_target` trigger and no `secrets.*` reference (deploy uses OIDC) — no meaningful supply-chain exposure, noted for completeness only.
- **`where-it-counts`**: the `{@html step.text}` latent-XSS pattern in `Scrollytelling.svelte` (now at `src/lib/components/Scrollytelling.svelte:48` after a file move) is unchanged and still provably fed only by hardcoded static strings — the Svelte 5/Vite 8 upgrade (PR #8) didn't touch this file or its data source. Still recommend swapping to plain `{step.text}` interpolation to remove the latent risk. Also newly noted: the Google Fonts stylesheet `<link>` in `src/app.html:11-12` has no SRI (low — dynamically generated per-UA CSS makes static SRI impractical here).
- **`Calculator2.0`**: CDN script includes for D3 and Supabase JS (`admin.html`, `index.html`) still have no `integrity`/`crossorigin` SRI attributes — unchanged from last cycle, no new CDN includes added.
- **`neo-control`**: `package.json`'s declared floors for `react-router-dom` (`^7.14.2`) and `vite` (`^8.0.9`) weren't bumped even though the lockfile now resolves to patched `7.18.1`/`8.1.3` — hygiene only, since `npm ci` against the committed lockfile installs the patched versions. Also: `README.md` references a `.env.example` file for onboarding that doesn't exist in the repo (DX issue, not security).
- **`sudoku`**: during the CRA→Vite migration (commit `55fc1ac`, 2026-07-09), compiled `dist/` build output was briefly committed, then untracked two commits later the same day (`18bea39`, `a6de5b3`) and `.gitignore` now correctly excludes it. No secrets were ever present in the bundle (pure client-side SPA, no env vars). Historical-only, already self-resolved.

---

## ✅ Resolved Since Last Scan

1. **`sudoku` — CRA/react-scripts toolchain (57 vulnerabilities, 2 critical / 24 high) — RESOLVED.** Full migration off Create React App to Vite (commits `55fc1ac`, `fc2733d`, `bf9d20a`, `9b39fea`, 2026-07-09). `react-scripts` no longer appears anywhere in the lockfile; current toolchain (`vite@7.3.6`, `esbuild@0.28.1`, `vitest@3.2.7`) has no known critical/high CVEs.
2. **`neo-control` — outdated `react-router-dom`/`vite` with known CVEs — RESOLVED.** Lockfile now resolves `react-router-dom@7.18.1` and `vite@8.1.3` (commits `ccb1e49`, `6819dd2`), past the previously-flagged vulnerable versions. `js-yaml`/`brace-expansion` transitive deps also bumped.
3. **`neo-control` — client-side admin password gate — RESOLVED at the code level.** Replaced with real `supabase.auth.signInWithPassword()` + RLS-as-guard (commit `ceef7ece9`), matching the repo's documented security model. (The leaked passphrase value itself remains permanently burned — see Critical findings.)

---

## Repos With No New Issues Found (deep-scanned, clean or only carried-forward low items)

- **`amanda-repository`** — Karma→Vitest migration (PR #14) introduced no new secrets, no new XSS surface, no RLS/CI regressions. The 2026-06-14 burned credential remains correctly absent from all current tracked files.
- **`where-it-counts`** — Svelte 5 / Vite 8 upgrade (PR #8) introduced no new vulnerabilities; only the pre-existing low-severity latent-XSS item carries forward.

## Repos Not Updated Since Last Scan (skipped this cycle — no new commits)

`true-cost-of-car-ownership` (2026-06-30), `amandarae220` profile (2026-05-29), `doteon` (2026-05-29), `scamlessgames` (2026-05-23), `tamagotchi-game` (2026-04-22), `DungeonsAndDragons` (2025-12-05), `interactiveResume` (2024-07-28), `habitTracker` (2024-03-09). Their last-reported findings (2026-07-04 report and earlier) stand unchanged.

---

## Top Actions (ranked)

1. **Treat neo-control's old admin passphrase as permanently burned** — confirm it isn't reused as the live Supabase account password or anywhere else. The code-level fix (Supabase Auth + RLS) is already in place and closes the actual exploit path.
2. **Fix `Calculator2.0`'s stored-XSS in `admin.html` (device/browser → innerHTML)** — open for two consecutive scan cycles now with a clear, unauthenticated attacker-reachable path. Use `textContent`/`createElement` + a DB-level CHECK constraint.
3. **Verify `screenprops`' Supabase RLS policies live in the dashboard** — also open for two cycles; client code alone can't confirm the `projects` table is actually protected.
4. **Adopt a hard rule for this recurring scan: never quote a live or burned credential verbatim in a committed report.** The 2026-07-04 report's inclusion of two real credential values leaked them a second time into `dotfiles`' own git history.
5. Housekeeping: bump `amanda-repository`'s `vitest` floor past `^4.1.10`, and align `neo-control`'s `package.json` dependency floors with its already-patched lockfile versions.
