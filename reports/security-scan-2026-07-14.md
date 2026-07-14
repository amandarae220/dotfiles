# Security Scan — 2026-07-14

## Scope & Methodology

This is a delta scan against the prior run (`reports/security-scan-2026-07-04.md`, first-run baseline across all 15 accessible repos). Each repo's latest commit was compared to that baseline's checkpoint table; only repos with new commits since then were deep-scanned. Repos with no new commits were skipped per the baseline's own recommendation.

Each updated repo was scanned (read-only, no files modified) for: exposed secrets/credentials (tracked + full git history in the diff range), XSS-class injection risks, dependency vulnerabilities (`npm audit` where applicable), and exposed/unauthenticated API surface — with particular attention to whether prior findings from the 2026-07-04 scan were fixed, worsened, or left untouched.

## Repos Updated Since Last Scan — Deep-Scanned

| Repo | Prior Commit (07-04) | Current Commit | Date | Owner |
|---|---|---|---|---|
| neo-control | `144f5d2` | `97e4243` | 2026-07-08 | amandarae220 |
| dotfiles | `e763a29` | `90b9cb1` | 2026-07-07 | amandarae220 |
| where-it-counts | `218684e` | `32084ee` | 2026-07-09 | amandarae220 |
| amanda-repository | `131a77c` | `3dddcfd` | 2026-07-09 | amandarae220 |
| Calculator2.0 | `3a4bcf9` | `93e0ae5` | 2026-07-07 | amandarae220 |
| screenprops | `19fe372` | `fb5662a` | 2026-07-10 | amandarae220 |
| sudoku | `a833819` | `b0788f2` | 2026-07-10 | amandarae220 |

7 of 15 accessible repos had new commits and were deep-scanned. Findings: **0 critical, 1 high, 1 medium, 4 low/informational.**

## Repos Unchanged Since Last Scan — Skipped

| Repo | Last Commit | Date | Owner |
|---|---|---|---|
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | amandarae220 |
| amandarae220 (profile) | `2bc6ffb` | 2026-05-29 | amandarae220 |
| doteon | `5413b63` | 2026-05-29 | amandarae220 |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 |

No new commits on these 8 — their 2026-07-04 findings stand unchanged and were not re-verified in this run.

---

## 🔴 High

- **`Calculator2.0`**: `admin.html:551-552` — **The stored-XSS finding from 2026-07-04 is still present, unfixed.** `device`/`browser` values from the public-anon-writable `calculator_events` table are still concatenated into `innerHTML` for `<option>` tags. This range (`3a4bcf9..93e0ae5`) only touched `CLAUDE.md` and `README.md` — `admin.html` itself has not been changed at all since the finding was reported. **Action: fix now** — swap to `document.createElement`/`textContent`, and add a DB-level allow-list/CHECK constraint on `device`/`browser`.

## 🟡 Medium

- **`neo-control`**: The 2026-07-04 CRITICAL (`VITE_ADMIN_PASS` plaintext in `CONTEXT.md`) is **mechanism-fixed but not history-scrubbed**. `ceef7ec` replaced the client-side password gate with real Supabase `signInWithPassword` auth, and the doc references were removed (`fa0f370`) — the current working tree is clean. But the literal old passphrase (`checkadmininsights`) remains permanently recoverable via `git log --all -p -- CONTEXT.md`, since it appears in a pre-fix commit and again in the `-` (removed) side of the fix commit's own diff. Downgraded from critical (no longer live/exploitable as an auth bypass) to medium (a secret-hygiene / credential-hygiene residual). **Action: rotate that passphrase anywhere it was reused, and if a history rewrite (filter-repo/BFG) is ever done for another reason, purge this at the same time** — not urgent enough alone to justify a solo force-push history rewrite.

## 🟢 Low / Informational

- **`neo-control`** (additional): HIGH dependency CVEs from the last scan are fully resolved — `react-router-dom` → 7.18.1, `vite` → 8.1.3, both past the flagged versions; `npm audit` now reports 0 vulnerabilities. The MEDIUM `js-yaml`/`brace-expansion` transitive-dep note is also resolved (current versions are non-vulnerable).
- **`sudoku`**: HIGH toolchain finding from the last scan (57 vulnerabilities, 2 critical/24 high, unmaintained CRA/react-scripts) is **fully resolved** — the repo migrated off CRA to Vite 7 entirely; `npm audit` now reports 0 vulnerabilities at any severity. New localStorage-backed best-time feature renders only through React's default JSX escaping (no `innerHTML`).
- **`Calculator2.0`** (additional): CDN scripts (D3, Supabase JS) still lack Subresource Integrity — unchanged from last scan. Also noted: `event_type` from the same anon-writable table is concatenated into a CSS `className` string (not `innerHTML`) — not script-executable, but worth an allow-list at low priority.
- **`amanda-repository`**: 2 low-severity dev-only `npm audit` findings introduced by the new Angular 22/vitest toolchain (`@babel/core` sourcemap file-read GHSA-4x5r-pxfx-6jf8, `esbuild` dev-server file-read GHSA-g7r4-m6w7-qqqr) — both build-time/dev-server-only exposure, no production runtime path. Also reconfirmed a pre-existing (not new) doc/reality mismatch: this repo's `CLAUDE.md` states `environment.ts` is gitignored, but it's actually tracked with the real Supabase URL + anon key — consistent with Supabase's intended public-anon-key + RLS pattern, but the doc claim is inaccurate.
- **`where-it-counts`**: The latent `{@html step.text}` note from the last scan is unchanged (Svelte 5 upgrade didn't touch that component or its data flow — still hardcoded static strings, still not exploitable today). One pre-existing low-severity transitive `cookie@0.6.0` advisory via `@sveltejs/kit` was already present before this update, not introduced by it, and isn't exploitable on this static-prerendered site.
- **`screenprops`**: New `/pricing` page is static marketing content with no payment/checkout integration yet — flagging only so the next scan re-audits for price-tampering and webhook-secret handling once real billing is wired up. `npm audit` shows 3 moderate transitive `postcss` findings via `next`/`@vercel/analytics`; no viable non-regressive fix path exists yet upstream (build-time only, low real-world exploitability).
- **`dotfiles`**: No new issues. Only change of note: `reports/audit-2026-06-16.md` was edited to redact a real plaintext password that had previously been quoted verbatim from an `amanda-repository` finding — a report-hygiene fix, not a new problem (confirm that password was rotated in its source repo if not already done).

---

## Repos With No New Issues (Confirmed Clean This Run)

- **dotfiles** — additive skill-doc commits only, no secrets, no script changes.
- **where-it-counts** — dependency upgrade + accessibility/copy changes, no new attack surface.
- **amanda-repository** — toolchain migration (vitest, Angular 22), no auth-model changes, no new secrets.
- **screenprops** — pricing page + a11y fix, no secrets, no API routes exist yet.
- **sudoku** — full CRA→Vite migration closed out all prior findings; nothing new introduced.

---

## Top Actions (ranked)

1. **Fix `Calculator2.0`'s `admin.html:551-552` stored-XSS now** — this is the same HIGH finding from ten days ago, and the file hasn't been touched since it was flagged. Swap `innerHTML` string concatenation for `textContent`/`createElement`.
2. **Rotate the old `neo-control` admin passphrase** (`checkadmininsights`) anywhere it was reused — the live auth bypass is closed (real Supabase auth is in place), but the string itself is permanently exposed in git history.
3. No other action items rise above low/informational this cycle — `neo-control`'s dependency CVEs and `sudoku`'s entire CRA toolchain debt are both fully resolved, which is the best news in this run.
