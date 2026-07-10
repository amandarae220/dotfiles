# Security Scan — 2026-07-10

## Scope & Methodology

Incremental run against the 2026-07-04 baseline (`reports/security-scan-2026-07-04.md`). Each of the 15 accessible repos' current HEAD was compared by commit SHA against that baseline's checkpoint table. **7 repos had new commits and were deep-scanned** (diff-focused, read-only, no files modified); **8 repos were unchanged (identical SHA) and skipped** per the recurring-scan protocol.

## Repos With New Commits — Deep-Scanned

| Repo | Prior Commit | Current Commit | Date | Owner |
|---|---|---|---|---|
| dotfiles | `e763a29` | `90b9cb1` | 2026-07-07 | amandarae220 |
| where-it-counts | `218684e` | `32084ee` | 2026-07-09 | amandarae220 |
| neo-control | `144f5d2` | `97e4243` | 2026-07-08 | amandarae220 |
| amanda-repository | `131a77c` | `3dddcfd` | 2026-07-09 | amandarae220 |
| Calculator2.0 | `3a4bcf9` | `93e0ae5` | 2026-07-07 | amandarae220 |
| screenprops | `19fe372` | `6b6e0f8` | 2026-07-09 | amandarae220 |
| sudoku | `a833819` | `623b4cc` | 2026-07-09 | amandarae220 |

## Repos Unchanged Since Last Scan — Skipped

| Repo | Commit | Date | Owner |
|---|---|---|---|
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-29/30 | amandarae220 |
| amandarae220 (profile) | `2bc6ffb` | 2026-05-29 | amandarae220 |
| doteon | `5413b63` | 2026-05-29 | amandarae220 |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 |

Findings this run: **0 critical, 1 high (carried over, unfixed), 1 medium (newly surfaced), 4 low/informational.** Two prior high-severity findings and one prior critical finding were verified as **fixed**.

---

## 🚨 Critical

None. The prior critical finding (`neo-control` live exposed admin credential) is closed — see Fixed section below.

## 🔴 High

- **`Calculator2.0` — stored XSS in `admin.html` — STILL UNFIXED (carried over from 2026-07-04)**
  `admin.html:551-552` still concatenates `device`/`browser` values straight into `innerHTML` for the filter-dropdown `<option>` tags:
  ```js
  deviceSel.innerHTML  = '<option value="">All devices</option>'  + devices.map(function (d)  { return '<option>' + d + '</option>'; }).join('');
  browserSel.innerHTML = '<option value="">All browsers</option>' + browsers.map(function (b) { return '<option>' + b + '</option>'; }).join('');
  ```
  Verified byte-for-byte unchanged (`git diff 3a4bcf9..93e0ae5 -- admin.html` is empty) despite the branch being named `feature/angular-makeover` — no framework migration actually occurred; the file is still ES5/no-build. Exploit path re-confirmed: `docs/calculator_events_schema.sql` grants anon `INSERT ... with check (true)` on the `calculator_events` table with no validation on the `device`/`browser` text columns, so an attacker can POST a script payload directly to the Supabase REST endpoint, bypassing the client-side helper functions, and it executes in the admin's browser (persistent session) on next dashboard load. By contrast, the event-feed renderer elsewhere in the same file (`admin.html:790-808`) already does this safely via `createElement` + `textContent` — the fix pattern already exists in-repo, it just wasn't applied to the filter-dropdown code path.
  **Action: apply the same `createElement`/`textContent` pattern to lines 551-552, or add a DB-level allow-list/CHECK constraint on `device`/`browser`.**

## 🟡 Medium

- **`screenprops` — `postcss <8.5.10` moderate XSS advisory (newly surfaced, pre-existing in the dependency tree)**
  `npm audit --production` reports a moderate vulnerability (unescaped `</style>` in CSS stringify output) in `postcss`, pulled in transitively via `next` → `@vercel/analytics`. Not introduced by the one new commit scanned this run (`package.json`/`package-lock.json` untouched by it) and wasn't called out in the 2026-07-04 report — flagging now so it's tracked going forward. `npm audit fix --force` would downgrade `next` (breaking); recommend evaluating a targeted `postcss` bump first.

## 🟢 Low / Informational

- **`amanda-repository`**: the Karma→Vitest migration pulled in `vite`/`esbuild`/`@angular/build` as new dev-time transitive dependencies, surfacing 3 low-severity advisories (`@babel/core` arbitrary file read via `sourceMappingURL`, `esbuild` Windows dev-server file read). Dev/build-time only, not shipped to production. `npm audit fix` when convenient.
- **`Calculator2.0`**: CDN scripts (D3, Supabase JS) in both `index.html` and `admin.html` still load without `integrity`/`crossorigin` SRI attributes — unchanged from 2026-07-04, still open.
- **`where-it-counts`**: `Scrollytelling.svelte:51`'s `{@html step.text}` on hardcoded static strings remains unchanged and non-exploitable (confirmed `surplusSteps` is still a literal array, not CMS/API-sourced) — same latent-risk note as last scan. Separately, `cookie <0.7.0` (GHSA-pxg6-pf52-xh8x) is pinned transitively via `@sveltejs/adapter-static`; confirmed pre-existing (same pin before and after the Svelte 5/Vite 8 upgrade), low practical risk on a prerendered static site with no server-side cookie handling.
- **`neo-control`**: Supabase RLS policy enforcement (anon INSERT / authenticated SELECT) is documented in README/CLAUDE.md and referenced in code, but the actual policy configuration lives in the Supabase project itself and can't be verified from source — recommend confirming directly in the Supabase dashboard for full close-out confidence on the fix below.

---

## ✅ Fixed Since Last Scan

**`neo-control` — critical exposed admin credential — FIXED.**
`VITE_ADMIN_PASS` and its literal value are fully purged from the current tree (`CLAUDE.md` now only contains prohibitive language: "do not re-introduce ... has been permanently removed"). The client-side string-compare auth in `AdminPage.tsx` was replaced with real `supabase.auth.signInWithPassword()` + session restore + `signOut()` (commit `ceef7ec`). The literal old credential still exists in git history prior to `144f5d2` — that was already known and flagged in the 2026-07-04 report as a separate (lower-priority) historical-purge item, not a live exposure.

**`neo-control` — high-severity `react-router-dom`/`vite` CVEs — FIXED.**
Bumped `react-router-dom` 7.14.2 → 7.18.1 and `vite` 8.0.9 → 8.1.3 (commit `ccb1e49`, "npm audit fix"). Verified via direct `npm audit` on both commits: 6 vulnerabilities (1 low, 2 moderate, 3 high) before → **0 vulnerabilities** after.

**`neo-control` — medium `js-yaml`/`brace-expansion` DoS advisories — FIXED.**
`js-yaml` 4.1.1 → 4.3.0; nested `brace-expansion` copy 5.0.2-5.0.5 → 5.0.7. Confirmed via `npm audit` diff.

**`sudoku` — high-severity CRA/`react-scripts` toolchain (57 vulnerabilities, 2 critical/24 high, dev-only) — FIXED.**
Full migration off Create React App to Vite 7 + Vitest 3. `react-scripts` is completely absent from `package.json` and `package-lock.json` (lockfile shrank from ~19,700 to 3,642 lines, confirming the dependency tree was actually dropped). Recommend a follow-up `npm install && npm audit --production` once dependencies are freshly installed to get a concrete zero-advisory confirmation, but structurally the fix is in place.

---

## Repos Scanned This Run With No Issues Found

- **`dotfiles`**: diff was entirely skill/doc additions plus two report files; one of the report files (`audit-2026-06-16.md`) had a previously plaintext-exposed password redacted to `[REDACTED]` in this diff — a remediation, not a new exposure.
- **`where-it-counts`**: Svelte 5 / Vite 8 upgrade plus a11y polish and a footer disclaimer; no new secrets, injection risk, or insecure transport.
- **`amanda-repository`** (beyond the low finding above): Angular 21→22, Express 4→5 upgrades were mechanical; no template/auth/analytics logic changed.
- **`screenprops`** (beyond the medium finding above): new static pricing page, no data queries, no payment integration, no new API routes.

---

## Top Actions (ranked)

1. **Fix the stored-XSS path in `Calculator2.0`'s `admin.html:551-552`** — this has now persisted across two scan cycles unaddressed. The safe pattern (`createElement`/`textContent`) already exists elsewhere in the same file; apply it here.
2. Track and patch the `screenprops` transitive `postcss` moderate advisory — evaluate a targeted bump before reaching for `npm audit fix --force`.
3. Confirm `neo-control`'s Supabase RLS policies directly in the dashboard to fully close out the credential-exposure remediation (code-side fix is verified; server-side policy isn't independently checkable from source).
4. Routine `npm audit fix` sweep for the newly surfaced low-severity dev-only transitives in `amanda-repository`.
