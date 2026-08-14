# Security Scan — 2026-08-14

## Scope & Methodology

Incremental scan against the baseline in [`security-scan-2026-07-04.md`](./security-scan-2026-07-04.md). Each of the 15 accessible repos' current default-branch HEAD was diffed against its checkpoint SHA from the prior run. Repos with no new commits were skipped (no code changed, nothing new to find). The 8 repos with new commits were scanned in full: diff review since the checkpoint SHA plus a general pass for exposed secrets/credentials (including new git history), XSS-class injection, dependency vulnerabilities, insecure transport, and exposed/unauthenticated API surface. Prior open findings were specifically re-checked for remediation status.

## Repos Scanned — Checkpoint for Next Run

| Repo | Last Commit | Date | Status |
|---|---|---|---|
| neo-control | `683fac2` | 2026-08-13 | Scanned — changed |
| dotfiles | `9e31777` | 2026-07-30 | Scanned — changed |
| where-it-counts | `32084ee` | 2026-08-05 | Scanned — changed |
| amanda-repository | `01b0786` | 2026-08-10 | Scanned — changed |
| Calculator2.0 | `d68de4a` | 2026-08-09 | Scanned — changed |
| screenprops | `fb5662a` | 2026-08-02 | Scanned — changed |
| amandarae220 (profile) | `24d9a2c` | 2026-08-01 | Scanned — changed |
| sudoku | `923a3c1` | 2026-08-12 | Scanned — changed |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | No new commits — skipped |
| doteon | `5413b63` | 2026-05-29 | No new commits — skipped |
| scamlessgames | `5303ffc` | 2026-05-23 | No new commits — skipped |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | No new commits — skipped |
| tamagotchi-game | `a322c7f` | 2026-04-22 | No new commits — skipped |
| interactiveResume | `3e638ca` | 2024-07-28 | No new commits — skipped |
| habitTracker | `5b4aef4` | 2024-03-09 | No new commits — skipped |

8 of 15 repos had activity since the last scan and were deep-scanned. 7 were unchanged and skipped per the incremental methodology. Findings: **1 critical, 1 high, 3 medium, 3 low, several informational.** 2 prior HIGH findings confirmed **resolved**.

---

## 🚨 Critical

**`neo-control` — the previously-rotated admin password was briefly reintroduced into tracked history and remains retrievable**
The 2026-07-04 scan flagged a live plaintext `VITE_ADMIN_PASS` in `CONTEXT.md`. Commit `fa0f370` (before this scan window) removed it correctly. But two commits added *since* the last checkpoint — `e70633a` and `eb420918` — briefly reverted `CONTEXT.md:101` back to a client-side password gate, reintroducing the literal value `checkadmininsights` into the file before a later commit (`ceef7ec`) replaced it with Supabase auth again. Net effect: HEAD is clean, but the plaintext password sits in the repo's committed, pushed git history at `amandarae220/neo-control` and is retrievable via `git log -p` by anyone with clone access.
- **Action: treat `checkadmininsights` as burned — rotate anywhere it's reused. Purge it from history with `git filter-repo`/BFG if you're prepared to force-push (coordinate first, this rewrites shared history).**

## 🔴 High

- **`neo-control`**: `react-router-dom` was bumped to `7.18.1` (up from the previously-flagged `7.14.2`) but this is still inside the vulnerable range (`7.12.0–7.18.1`) for the RSC-mode CSRF bypass (GHSA-qwww-vcr4-c8h2). Needs a bump past `7.18.1` once a patched release is available. (Vite's separate CVE from the last scan is now resolved at `8.1.3`.)

## 🟡 Medium

- **`neo-control`**: `js-yaml` (`4.3.0`) and `brace-expansion` DoS advisories flagged in the last scan are still present and unpatched — `npm audit fix`. `npm audit` also newly flags `nanoid` and `postcss` (high-severity transitive deps) — not part of the original findings, worth a follow-up pass.
- **`where-it-counts`**: the Svelte 4→5 / Vite 5→8 upgrade pulled in vulnerable transitive **dev** dependencies (`postcss <=8.5.22` path traversal, `nanoid <=3.3.17` infinite loop, `@sveltejs/kit`/`cookie` ReDoS). Production build is fully static/prerendered (`adapter-static`) with 0 vulnerabilities on `npm audit --production`, so there's no production attack surface — only matters if `vite dev` is ever exposed. `npm audit fix` recommended anyway for hygiene.
- **`screenprops`**: unchanged from last scan — ownership scoping on the `projects` table is still enforced only in client-side Supabase queries with the public anon key. No server-side route handlers or RLS migrations exist in-repo to verify against. Can't confirm actual RLS state from code alone — verify in the Supabase dashboard.

## 🟢 Low / Informational

- **`where-it-counts`**: `Scrollytelling.svelte:51`'s `{@html step.text}` on hardcoded static strings — still latent, not exploitable today, unchanged from last scan.
- **`Calculator2.0`**: CDN scripts (D3, Supabase JS) still load without SRI — unchanged from last scan.
- **`amanda-repository`**: new `?owner=1` analytics opt-out flag (`visitor.service.ts:24-38`) is a client-side-only `localStorage` marker with no server validation — trivially spoofable, degrades analytics integrity but exposes no data. New `public/calculator-v2/assets/config.js` carries the same intended-public Supabase URL/anon-key pattern as the root app.
- **`amanda-repository`**: the new project-assembly pipeline (vendoring Calculator2.0/D&D/sudoku/resume sub-apps into `public/`) correctly excludes `docs/`, `CLAUDE.md`, and lockfiles from what ships — confirmed the RLS-policy SQL source isn't bundled. Committed build artifacts under `public/*` sit against the pipeline's own documented "no committed artifacts" direction — a cleanup item, not a vulnerability.
- **`dotfiles`**: the previously-flagged plaintext password quoted in `reports/audit-2026-06-16.md` remains redacted (`[REDACTED]`) as of the last scan — reconfirmed still redacted, no recurrence.

---

## ✅ Resolved Since Last Scan

- **`Calculator2.0`** (was HIGH): the stored-XSS in `admin.html` — DB-sourced `device`/`browser` values concatenated into `innerHTML` — is fixed. Confirmed replaced with `createElement`/`textContent` via a new `populateSelect()` helper. A related risk (`event_type` interpolated into a CSS class name, also anon-writable) was proactively hardened with a `safeEventTypeClass()` allowlist in the same diff.
- **`sudoku`** (was HIGH): the unmaintained CRA/`react-scripts` toolchain (57 `npm audit` findings, 2 critical/24 high) is gone — the repo fully migrated to Vite 7 + Vitest 3 + TypeScript 5.7 in a 28-commit rewrite. No equivalent vulnerability chain in the new toolchain.
- **`neo-control`** (partial): the admin-gate logic itself is confirmed moved server-side — `AdminPage.tsx` now uses `supabase.auth.signInWithPassword()` with no client-side string compare, and `sessions.ts` correctly separates anon-key INSERT from authenticated-session SELECT. The credential-exposure part of this finding is **not** resolved — see Critical, above.

## Repos With No New Activity (skipped this run)

true-cost-of-car-ownership, doteon, scamlessgames, DungeonsAndDragons, tamagotchi-game, interactiveResume, habitTracker — no commits since their 2026-07-04 checkpoint SHAs. Their last-known status (all clean or dev-only findings) stands from the prior report; not re-verified this run.

---

## Top Actions (ranked)

1. **Treat `checkadmininsights` (neo-control) as a burned credential** — rotate anywhere it's reused, and decide whether to purge it from git history via `git filter-repo`/BFG (requires a coordinated force-push).
2. **Bump `react-router-dom` in `neo-control`** past `7.18.1` once a patched release lands — the CSRF bypass range wasn't fully cleared by the last bump.
3. **Run `npm audit fix` in `neo-control`** for `js-yaml`, `brace-expansion`, and the newly-flagged `nanoid`/`postcss`.
4. **Verify `screenprops`' `projects` table RLS policy directly in the Supabase dashboard** — code alone can't confirm server-side enforcement exists.
5. No action needed on `Calculator2.0`'s XSS or `sudoku`'s toolchain — both closed.
