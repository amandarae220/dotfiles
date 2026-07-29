# Security Scan — 2026-07-29

## Scope & Methodology

Diff-based run against the checkpoint in `reports/security-scan-2026-07-04.md` (2026-07-04). Each of the 15 accessible repos' latest default-branch commit was compared to its 2026-07-04 checkpoint SHA. **8 of 15 repos had new commits** and were deep-scanned (read-only; secrets in tracked files + full diff history, XSS-class injection, dependency vulnerabilities, insecure transport, exposed API surface). The other **7 repos are byte-for-byte unchanged** since 2026-07-04 and were skipped per the recurring-scan protocol.

## Repos Scanned — Checkpoint for Next Run

| Repo | Last Commit | Date | Status |
|---|---|---|---|
| dotfiles | `fc35e81` | 2026-07-29 | Scanned — changed |
| where-it-counts | `32084ee` | 2026-07-09 | Scanned — changed (Svelte 5 / Vite 8 upgrade) |
| neo-control | `97e4243` | 2026-07-08 | Scanned — changed |
| Calculator2.0 | `93e0ae5` | 2026-07-07 | Scanned — changed |
| screenprops | `fb5662a` | 2026-07-10 | Scanned — changed |
| amanda-repository | `76469b9` | 2026-07-28 | Scanned — changed (vendored Calculator2.0/DnD/sudoku/resume as sub-apps) |
| amandarae220 (profile) | `24d9a2c` | 2026-07-28 | Scanned — changed (README-only repo, no security surface) |
| sudoku | `512f1f4` | 2026-07-28 | Scanned — changed (v2 redesign, CRA → Vite) |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | Unchanged — skipped |
| doteon | `5413b63` | 2026-05-29 | Unchanged — skipped |
| scamlessgames | `5303ffc` | 2026-05-23 | Unchanged — skipped |
| tamagotchi-game | `a322c7f` | 2026-04-22 | Unchanged — skipped |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | Unchanged — skipped |
| interactiveResume | `3e638ca` | 2024-07-28 | Unchanged — skipped |
| habitTracker | `5b4aef4` | 2024-03-09 | Unchanged — skipped |

Findings this run: **0 critical, 4 high, 1 medium, 5 low/informational.** One previously-flagged critical (neo-control) confirmed resolved.

---

## 🔴 High

- **`Calculator2.0` — stored XSS still unresolved (carried over from 2026-07-04, unfixed)**
  `SECURITY [severity: high]: admin.html:551-552 — device/browser values from the anon-writable calculator_events Supabase table are concatenated raw into innerHTML for <option> tags.` Anyone holding the public anon key (in `assets/config.js`, intentionally public) can INSERT a row with `device: "<img src=x onerror=...>"` and it executes in the admin's authenticated session on next dashboard load. **Notably, this was already fixed in the copy vendored into `amanda-repository/public/calculator-v2/admin.html` (commit history there shows `populateSelect()` rebuilt with `textContent`/`createElement`, with a comment documenting the exact attack) — but the fix was never backported to the Calculator2.0 source repo itself, which is what actually deploys to GitHub Pages.** Action: port the `populateSelect()` fix from the vendored copy back into `Calculator2.0/admin.html`.

- **`neo-control` — react-router-dom in a newly-disclosed vulnerable range**
  `SECURITY [severity: high]: package-lock.json — react-router-dom 7.18.1 — GHSA-qwww-vcr4-c8h2 (RSC Mode CSRF Bypass Allows Action Execution Before 400 Response), vulnerable range 7.12.0–8.2.0.` This version was introduced by the same `npm audit fix` commit that resolved the previous vite CVE — the fix didn't cover this route. No patched release exists in-range yet; `npm audit fix --force` only offers a breaking downgrade to 7.11.0. Action: pin to `<7.12.0` or track for a patched release.

- **`sudoku` — dev-toolchain path traversal (build-time only)**
  `SECURITY [severity: high]: package-lock.json — postcss <=8.5.17 (transitive via Vite) — GHSA-r28c-9q8g-f849, arbitrary .map file disclosure via sourcemap auto-loading (CVSS 7.5).` Not shipped in the production bundle. Action: `npm audit fix`.

- **`amanda-repository` — 4 high-severity dev-toolchain advisories from the new Vitest migration**
  `SECURITY [severity: high]: package-lock.json — fast-uri, immutable, postcss (sourcemap path traversal, same GHSA-r28c-9q8g-f849 as sudoku) all flagged by npm audit, 12 total advisories.` All in devDependencies (vite/vitest/postcss toolchain), not shipped to the Express-served production build. Action: `npm audit fix`.

**Good news, confirmed resolved:** The 2026-07-04 critical in `neo-control` (`VITE_ADMIN_PASS` plaintext credential + client-side-only admin gate) is fully remediated — the literal value is gone from `CONTEXT.md`, and `AdminPage.tsx` now uses real Supabase `signInWithPassword` auth with session-based persistence. No client-side string compare remains anywhere in source.

## 🟡 Medium

- **`screenprops`**: Unchanged from 2026-07-04 — `projects` table authorization is still enforced only client-side (`.eq("user_id", user.id)`) with the public anon key; no RLS policy SQL exists anywhere in-repo to document or verify the boundary. Two new commits this cycle (pricing page, animation fix) don't touch this. Action: add `supabase/policies.sql` as the auditable source of truth, or move mutations behind server-side handlers.

## 🟢 Low / Informational

- **`dotfiles`**: A credential fragment (`admininsights`, the already-burned neo-control password) briefly appeared in plaintext in `reports/security-scan-2026-07-04.md` for one commit before being redacted in the very next commit. Already resolved at HEAD; flagged only as a process reminder to redact before committing draft reports, not after.
- **`where-it-counts`**: Two dev-time-only transitive advisories introduced by the Svelte 5/Vite 8 upgrade — `postcss <=8.5.17` (same sourcemap path-traversal GHSA as above) and `cookie <0.7.0` via `@sveltejs/kit`. `npm audit --omit=dev` (production deps) reports 0 vulnerabilities. The `{@html step.text}` in `Scrollytelling.svelte:51` remains fed only by hardcoded strings — unchanged latent-risk note from prior scans, no escalation.
- **`Calculator2.0`**: CDN scripts (D3, Supabase JS) still load without SRI — unchanged low-severity note from 2026-07-04.
- **`amanda-repository`**: The vendored Calculator2.0 rehost (`public/calculator-v2/`) copies dev/CI cruft (`.github/`, `docs/`, `.editorconfig`) into the deployed bundle via a broad `**/*` asset glob — no secrets in it, just unnecessary exposure of internal tooling. Prune the vendored tree before rehosting, or filter it in `express.static`.
- **`sudoku`**: Fully migrated off Create React App to Vite — the 57 vulnerabilities (2 critical) flagged against the CRA toolchain in the 2026-07-04 scan no longer apply; `react-scripts` is gone entirely.

---

## Repos With No Issues Found

- **amandarae220 (profile)** — repo now contains only `README.md`; no security surface to scan.
- **neo-control** — beyond the react-router-dom advisory above, no new secrets, no XSS sinks, no auth regressions in the changed files (`GameCanvas.tsx`, `AdminPage.tsx`, `sessions.ts`).
- **where-it-counts** — no new secrets, no insecure transport, no new server routes (still fully static/prerendered).
- **amanda-repository** — beyond the dev-toolchain advisories and vendored-cruft note, the stored-XSS pattern did *not* reappear (already fixed in the vendored copy), no `[innerHTML]`/`bypassSecurityTrust*` in the Angular app, and the `portfolio_events` RLS boundary (anon INSERT / authenticated SELECT) holds in all new code paths.

---

## Top Actions (ranked)

1. **Port the `admin.html` stored-XSS fix from `amanda-repository/public/calculator-v2/admin.html` back into the `Calculator2.0` source repo.** The fix already exists and is proven — it just hasn't been applied where the live GitHub Pages deployment actually builds from. This has now been open since the 2026-07-04 scan.
2. **Pin or patch `react-router-dom` in `neo-control`** — a fresh CSRF-bypass advisory (GHSA-qwww-vcr4-c8h2) affects the version a recent `npm audit fix` landed on.
3. **Add RLS policy SQL to `screenprops`** so the `projects`-table authorization boundary is documented and auditable rather than assumed.
4. Run `npm audit fix` in `sudoku` and `amanda-repository` for the dev-toolchain `postcss`/`fast-uri`/`immutable` advisories — low urgency (build-time only) but low-cost to clear.
5. Prune vendored dev/CI files out of `amanda-repository/public/calculator-v2/` before it's served publicly.
