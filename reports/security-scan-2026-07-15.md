# Security Scan — 2026-07-15

## Scope & Methodology

Incremental run. Compared each repo's current HEAD against the checkpoint table in `reports/security-scan-2026-07-04.md` (the prior run). **7 of 15 accessible repos had new commits since their checkpoint** and were deep-scanned; the other 8 were unchanged and skipped per the recurring-scan protocol. Each scanned repo was checked for: exposed secrets/credentials (tracked + relevant git history), XSS-class injection risks, dependency vulnerabilities, and re-verification of every previously open finding.

## Repos Scanned — Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Status this run |
|---|---|---|---|---|
| dotfiles | `90b9cb1` | 2026-07-07 | amandarae220 | scanned |
| where-it-counts | `32084ee` | 2026-07-09 | amandarae220 | scanned |
| neo-control | `97e4243` | 2026-07-08 | amandarae220 | scanned |
| amanda-repository | `3dddcfd` | 2026-07-09 | amandarae220 | scanned |
| Calculator2.0 | `93e0ae5` | 2026-07-07 | amandarae220 | scanned |
| screenprops | `fb5662a` | 2026-07-10 | amandarae220 | scanned |
| sudoku | `b0788f2` | 2026-07-10 | amandarae220 | scanned |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | amandarae220 | unchanged — skipped |
| amandarae220 (profile) | `2bc6ffb` | 2026-05-29 | amandarae220 | unchanged — skipped |
| doteon | `5413b63` | 2026-05-29 | amandarae220 | unchanged — skipped |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ | unchanged — skipped |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 | unchanged — skipped |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 | unchanged — skipped |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 | unchanged — skipped |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 | unchanged — skipped |

7 of 7 updated repos scanned. Findings this run: **0 critical, 1 high, 2 medium, 2 low/informational** — plus 6 prior findings confirmed **resolved**.

---

## 🔴 High

- **`Calculator2.0`** — **still open, unchanged since 2026-06-18.** `admin.html`, in `populateDeviceAndBrowserFilters()`, still concatenates unescaped `device`/`browser` values (sourced from the anon-writable `calculator_events` Supabase table) straight into `innerHTML`:
  ```js
  deviceSel.innerHTML = '<option value="">All devices</option>' + devices.map(function (d) { return '<option>' + d + '</option>'; }).join('');
  ```
  The RLS insert policy (`with check (true)`) still allows any anonymous client to write attacker-controlled markup that executes in the admin's persistent authenticated session. Note: the branch merged this cycle was named `feature/angular-makeover`, which suggested a rewrite — it was actually a **docs-only PR** (`CLAUDE.md` + `README.md`, 139 lines, zero app code). No migration occurred; the vulnerable code is untouched. Fix: swap to `textContent`/`createElement`, matching the pattern already used correctly elsewhere in the same file (`renderEventBreakdown`, `renderFeed`).

## 🟡 Medium

- **`dotfiles`** — **new this cycle: a secondary credential leak, self-inflicted by the scanning process itself.** The 2026-07-04 report (`reports/security-scan-2026-07-04.md`) was committed with two real plaintext credentials quoted verbatim in its body: neo-control's `VITE_ADMIN_PASS` value and amanda-repository's already-burned password. Both were redacted three days later in commit `b14409e` — current HEAD is clean — but neither value was scrubbed from git history, so both remain permanently retrievable via `git log --all -p` on this repo. One of the two (neo-control's) was, per the report's own text, "live and currently exploitable" at the moment it was committed here. **Process fix: redact discovered secrets before the report is ever committed, not in a follow-up commit.**
- **`neo-control`** — **prior critical finding is code-fixed but leaves a residual exposure.** The client-side password gate is gone: `AdminPage.tsx` (commit `ceef7ece`) now uses `supabase.auth.signInWithPassword()` instead of comparing against `VITE_ADMIN_PASS`, and the last reference to the env var was removed from `CONTEXT.md` in `fa0f370` (2026-07-07). However, the literal value `checkadmininsights` sat in `CONTEXT.md` in plaintext for ~12 days past the prior checkpoint before being scrubbed (`6819dd2a`, 2026-07-05), and — per the dotfiles finding above — was independently copied into a *second* repo's history days later. It no longer functions as an auth bypass (auth moved to Supabase), but should be treated as a burned credential: **rotate `checkadmininsights` anywhere it may have been reused**, and consider a history purge (`git filter-repo`/BFG) on both repos if a clean history matters.
- **`screenprops`** — unchanged, still open. Ownership scoping on the `projects` table (`.eq("user_id", user.id)`) is enforced only client-side, with the public anon key, in both the SSR `SELECT` (`app/dashboard/page.tsx`) and the client-side `DELETE` (`DashboardClient.tsx`). No server-side route handlers or in-repo RLS policy files exist to confirm the real boundary. This cycle's two commits (a pricing page, a photosensitivity/reduced-motion animation fix) didn't touch this code path. **Still needs a live check of the Supabase dashboard RLS config** — unverifiable from source alone.

## 🟢 Low / Informational

- **`Calculator2.0`**: CDN scripts (D3 v7, Supabase JS `@2` floating tag) still load without SRI — unchanged from prior scan.
- **`where-it-counts`**: `Scrollytelling.svelte:51`'s `{@html step.text}` remains on hardcoded, non-API-sourced strings — unchanged, still latent-only. Also noting `cookie@0.6.0` (pre-existing transitive dep via SvelteKit) carries a known low/moderate advisory (GHSA-pxg6-pf52-xh8x, fixed 0.7.0) — not introduced this cycle, worth a future bump.

---

## ✅ Resolved Since Last Scan

- **`neo-control`** — HIGH: `react-router-dom`/`vite` CVE-affected versions → lockfile bumped to `7.18.1`/`8.1.3` (commit `ccb1e499`), past all known advisories.
- **`neo-control`** — MEDIUM: `js-yaml`/`brace-expansion` transitive DoS advisories → resolved in the same lockfile bump.
- **`neo-control`** — CRITICAL: client-side admin password gate → replaced with Supabase `signInWithPassword` (see residual note under Medium above).
- **`sudoku`** — HIGH: 57 `npm audit` findings (2 critical, 24 high) in the unmaintained `react-scripts`/CRA toolchain → repo migrated to Vite (`55fc1ac`, 2026-07-09), `react-scripts` fully removed. Recommend a fresh `npm audit` against the new toolchain next run to establish a clean baseline.
- **`where-it-counts`** — the Svelte 5 / Vite 8 upgrade removed `esbuild@0.21.5` from the dependency tree entirely (replaced by Rolldown), eliminating a known dev-server request-forgery advisory (GHSA-67mh-4wv8-2f99) that was present at the prior checkpoint.
- **`dotfiles`** — LOW: plaintext password quoted in `reports/audit-2026-06-16.md` → redacted at HEAD (commit `b14409e`); note the underlying value is still recoverable from pre-redaction history, same caveat as the new dotfiles finding above.

---

## Repos With No Issues Found

- **`amanda-repository`** — this cycle's only change was a Karma→Vitest test-runner migration (`3dddcfd`), confirmed test-infrastructure-only via full diff review: no auth, environment, or analytics files touched. Zero new findings.

## Repos Unchanged Since Last Scan (skipped)

`true-cost-of-car-ownership`, `amandarae220` (profile), `doteon`, `scamlessgames`, `tamagotchi-game`, `DungeonsAndDragons`, `interactiveResume`, `habitTracker` — no commits since their 2026-07-04 checkpoint. Findings from that run stand unchanged; see `reports/security-scan-2026-07-04.md`.

---

## Top Actions (ranked)

1. **Fix the stored-XSS in `Calculator2.0`'s `admin.html`** — flagged four weeks ago, still unfixed, attacker-reachable via the anon-writable events table. Swap `innerHTML` string concatenation for `textContent`/`createElement`.
2. **Rotate `checkadmininsights` wherever it may be reused** — it's now permanently recoverable from git history in two repos (`neo-control` and `dotfiles`). No longer a live bypass in `neo-control` itself, but treat as burned.
3. **Verify RLS is actually enabled on `screenprops`' `projects` table** in the Supabase dashboard — the code has no server-side enforcement to fall back on if it isn't.
4. **Process fix for this recurring scan**: redact any live credential found during a scan *before* committing the report — this cycle's own report file became a second leak vector for a credential the prior scan had just flagged.
5. Run `npm audit` against `sudoku`'s new Vite/Vitest toolchain next cycle to baseline the post-migration dependency tree.
