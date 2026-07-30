# Security Scan — 2026-07-30

## Scope & Methodology

Incremental scan. Baseline: `reports/security-scan-2026-07-04.md` (the prior run, 2026-07-04). Each of the 15 accessible repos' current default-branch HEAD was compared against that run's checkpoint table; only repos with new commits since their checkpoint were deep-scanned. Repos with no new commits were skipped per the incremental-scan policy (their last full scan remains the 2026-07-04 report).

Each updated repo was scanned (read-only, no files modified) for: exposed secrets/credentials, XSS-class injection risks, dependency vulnerabilities, insecure client-side auth patterns, and Supabase/RLS-boundary regressions — with specific attention to re-verifying every open finding from the 2026-07-04 report.

## Repos Scanned — Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Status |
|---|---|---|---|---|
| dotfiles | `9e31777` | 2026-07-30 | amandarae220 | ✅ scanned |
| where-it-counts | `32084ee` | 2026-07-09 | amandarae220 | ✅ scanned |
| neo-control | `97e4243` | 2026-07-08 | amandarae220 | ✅ scanned |
| amanda-repository | `76469b9` | 2026-07-28 | amandarae220 | ✅ scanned |
| Calculator2.0 | `a36134a` | 2026-07-30 | amandarae220 | ✅ scanned |
| screenprops | `fb5662a` | 2026-07-10 | amandarae220 | ✅ scanned |
| amandarae220 (profile) | `24d9a2c` | 2026-07-28 | amandarae220 | ✅ scanned |
| sudoku | `512f1f4` | 2026-07-28 | amandarae220 | ✅ scanned |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | amandarae220 | ⏭️ no new commits — skipped |
| doteon | `5413b63` | 2026-05-29 | amandarae220 | ⏭️ no new commits — skipped |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ | ⏭️ no new commits — skipped |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 | ⏭️ no new commits — skipped |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 | ⏭️ no new commits — skipped |
| sudoku (prior era) | — | — | — | superseded by v2-redesign above |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 | ⏭️ no new commits — skipped |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 | ⏭️ no new commits — skipped |

8 of 15 repos had new commits and were deep-scanned; 7 were unchanged and skipped. Findings this run: **0 critical, 2 high (both dev/build-time only), 1 medium, 3 low/informational.** Two previously-critical/high findings were confirmed **resolved**.

---

## ✅ Resolved Since Last Scan

- **`neo-control` — critical exposed-credential finding RESOLVED.** The plaintext `VITE_ADMIN_PASS` passphrase is fully removed from `CONTEXT.md` and the codebase (commit `fa0f370`). Admin auth now runs through real Supabase `signInWithPassword()` with session restore (commit `ceef7ec`) — the client-side string-compare gate is gone. `git grep` across the current tree finds only the rule text in `CLAUDE.md`, no live value.
- **`Calculator2.0` — high-severity stored-XSS in `admin.html` RESOLVED.** `populateDeviceAndBrowserFilters()` now builds `<option>` elements via `document.createElement` + `.textContent` instead of concatenating anon-writable `device`/`browser` fields into `innerHTML`. A related hardening also whitelists `event_type` before use in a CSS class name. All remaining `innerHTML` calls in the file assign only static hardcoded strings.
- **`sudoku` — CRA toolchain (57 vulns, 2 critical/24 high) RESOLVED via migration.** The v2 redesign moved off `react-scripts`/Create React App entirely onto Vite 7 + React 19 + Vitest 3; the CRA dependency tree (and its vulnerabilities) is gone.

## 🔴 High (dev/build-time only — no production exposure)

- **`sudoku`**: `postcss <=8.5.17` (transitive dep of `vite@^7.0.0`) — sourcemap path-traversal / arbitrary `.map` file disclosure (`GHSA-r28c-9q8g-f849`). `npm audit --omit=dev` reports 0 vulnerabilities, confirming this only affects the dev/CI toolchain, not the shipped bundle. Run `npm audit fix` / bump Vite before next CI run.
- **`neo-control`**: `npm audit` on the current lockfile still flags `brace-expansion` (DoS, dev-only via typescript-eslint) and `postcss` (same sourcemap path-traversal as above, build-time only) as high severity, plus `react-router-dom` 7.18.1 for an RSC-mode CSRF bypass (`GHSA-qwww-vcr4-c8h2`) — low real-world exploitability since this is a plain client SPA, not running React Server Components. `js-yaml`, previously flagged, is already resolved (commit `ccb1e49`).

## 🟡 Medium

- **`screenprops`**: The client-side-only `user_id` ownership-scoping pattern flagged on 2026-06-13 is now confirmed to span roughly 25 route files (`app/twitter/feed/page.tsx`, `app/tinder/swipe/page.tsx`, and others), not an isolated case — every one of them scopes Supabase reads/writes with `.eq("user_id", user.id)` from the browser using the public anon key, with no server-side route handlers or in-repo RLS policy definitions to verify against. None of these files were touched by the 2026-07-10 diff itself (an unrelated marketing-page + animation-fix commit), but the blast radius is now clearer. **Action: verify RLS is actually enabled and correctly scoped on every user-owned table in the live Supabase project** — this can't be confirmed from source alone.

## 🟢 Low / Informational

- **`amanda-repository`**: The "rehost calculator v1" PR vendors Calculator2.0's static build (`public/calculator-v1/`, `public/calculator-v2/`, plus `/dnd`, `/sudoku`, `/resume` static mounts) into this repo's Express server. It carries over Calculator2.0's existing missing-SRI issue — `d3.v5.min.js`/`d3.v7.min.js` and `@supabase/supabase-js@2` load from `d3js.org`/`cdn.jsdelivr.net` with no `integrity`/`crossorigin` attributes. Same low-severity supply-chain note as the standalone repo; now also present in the vendored copy. No secret leakage found in the vendored output — Calculator2.0's Supabase project config is its own, isolated from amanda-repository's.
- **`dotfiles`**: The plaintext-password quote in `reports/audit-2026-06-16.md:13` flagged as a low-severity issue on 2026-07-04 (a live copy of an already-burned credential) has been fixed — it now reads `[REDACTED]`. All newer report files (`audit-2026-07-29.md`, `audit-2026-07-30.md`, `security-scan-2026-07-04.md`) correctly redact credentials rather than quoting them verbatim.
- **`where-it-counts`**: `Scrollytelling.svelte:51`'s `{@html step.text}` on hardcoded static strings is unchanged by the Svelte 5 / Vite 8 upgrade — still latent-only, not exploitable today. Dependency bump verified clean: Vite 8.1.4 and SvelteKit 2.69.2 are both past the versions affected by their respective January 2026 CVEs.

---

## Repos With No Issues Found

- **amandarae220 (profile)** — diff was a cosmetic README rewrite only; no secrets, no workflows added, no embedded scripts.
- **Calculator2.0** — beyond the resolved stored-XSS (see above), the diff was small and introduced no new dependencies; the repo remains dependency-free per its no-build ADR.
- **neo-control** — beyond the dev-only dependency notes above, no secrets, no client-side-only auth, no `eval`/`innerHTML`/`dangerouslySetInnerHTML` in the diff.
- **where-it-counts** — no secrets, no new XSS surface, no CDN-without-SRI (all libs are npm-bundled, not CDN-loaded).

---

## Top Actions (ranked)

1. **`screenprops`**: Manually verify RLS is enabled and correctly scoped (`user_id = auth.uid()`) on every user-owned Supabase table — confirmed now to protect ~25 routes' worth of data, all currently relying on unverifiable client-side query filters as the only visible boundary.
2. Run `npm audit fix` on `sudoku` and `neo-control` for the dev-only `postcss`/`brace-expansion` findings before their next CI run — no production impact, but worth clearing before they accumulate.
3. No action required on `neo-control`'s `react-router-dom` RSC-CSRF flag — confirmed not applicable (this app doesn't run RSC), but keep on the radar if that changes.
4. Optional, low priority: add SRI attributes to the D3/Supabase CDN script tags shared by `Calculator2.0` and its vendored copy in `amanda-repository`.

**Repos unchanged since 2026-07-04 (not re-scanned):** true-cost-of-car-ownership, doteon, scamlessgames, DungeonsAndDragons, tamagotchi-game, interactiveResume, habitTracker. Their most recent findings remain those in `security-scan-2026-07-04.md`.
