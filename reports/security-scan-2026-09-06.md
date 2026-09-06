# Security Scan — 2026-09-06

## Scope & Methodology

Incremental scan against the checkpoint in `security-scan-2026-08-19.md`. Each of the 15 accessible repos' current HEAD commit was compared to that report's checkpoint table; only repos with new commits since the checkpoint were deep-scanned for vulnerabilities, exposed secrets, dependency issues, and code-quality concerns. Repos with an unchanged HEAD were skipped per protocol.

## Repos Scanned — Updated Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Status this run |
|---|---|---|---|---|
| dotfiles | `a28246c3` | 2026-08-27 | amandarae220 | Scanned — clean (report files only) |
| where-it-counts | `32084ee2` | 2026-07-09 | amandarae220 | No change since last scan — skipped |
| true-cost-of-car-ownership | `21dfc2d3` | 2026-06-30 | amandarae220 | No change since last scan — skipped |
| neo-control | `8c16c4a9` | 2026-08-26 | amandarae220 | Scanned — 6 HIGH dependency vulns open |
| amanda-repository | `01b0786c` | 2026-08-13 | amandarae220 | No change since last scan — skipped |
| Calculator2.0 | `d68de4a9` | 2026-08-13 | amandarae220 | No change since last scan — skipped |
| screenprops | `fb5662a0` | 2026-07-10 | amandarae220 | No change since last scan — skipped |
| amandarae220 (profile) | `24d9a2cf` | 2026-07-28 | amandarae220 | No change since last scan — skipped |
| doteon | `5413b63a` | 2026-05-29 | amandarae220 | No change since last scan — skipped |
| scamlessgames | `5303ffc2` | 2026-05-23 | psmithskynativ | No change since last scan — skipped |
| tamagotchi-game | `a322c7f5` | 2026-04-22 | amandarae220 | No change since last scan — skipped (see note below) |
| DungeonsAndDragons | `3ae9643f` | 2025-12-05 | amandarae220 | No change since last scan — skipped |
| sudoku | `69957efd` | 2026-08-26 | amandarae220 | Scanned — clean (v2-redesign) |
| interactiveResume | `3e638ca3` | 2024-07-28 | amandarae220 | No change since last scan — skipped |
| habitTracker | `5b4aef49` | 2024-03-09 | amandarae220 | No change since last scan — skipped |

**3 of 15 repos updated since 2026-08-19 and deep-scanned. 12 unchanged and skipped.**

---

## Security Issues Found — By Severity

### 🔴 High

**`neo-control` — 6 HIGH `npm audit` vulnerabilities, unpatched.** Confirmed directly against `package-lock.json` at HEAD (`8c16c4a9`); none of the 3 commits landed since the last scan (a docking-animation tweak, a spelling fix, and their merge) touched `package.json` or the lockfile, so these carry forward unresolved:

| Package | Installed | Advisory | Fix |
|---|---|---|---|
| react-router / react-router-dom | 7.18.1 | GHSA-qwww-vcr4-c8h2 — CSRF bypass in RSC mode (affects `>=7.12.0 <7.18.2`) | `npm i react-router-dom@7.18.2` |
| js-yaml | 4.3.0 | GHSA-5p4m-2wfm-xmqj — quadratic-CPU DoS in `!!omap` (CVE-2026-59870) | `npm audit fix` |
| postcss | 8.5.16 | GHSA-fxqj-rqcc-2cmp — path traversal via `sourceMappingURL` | `npm audit fix` |
| brace-expansion | 1.1.14 | GHSA-3jxr-9vmj-r5cp — DoS via exponential expansion | `npm audit fix` |
| nanoid | 3.3.15 | GHSA-28wg-ghj8-5hjv — infinite loop on negative size | `npm audit fix` |

This matches the dependency table already surfaced in the dotfiles code-quality series (`reports/audit-2026-08-26.md`); this report adds the direct security framing and lockfile confirmation. No secrets, auth regressions, or new unsafe patterns found elsewhere in the repo — `CONTEXT.md` still contains no `VITE_ADMIN_PASS` reference, and the admin dashboard's auth path is unchanged.

### 🟡 Medium (carried forward, unchanged — repos not touched this run)

- **`amanda-repository` — CRITICAL/historical, burned credential in git history.** No new commits this run; still open exactly as described in the 2026-08-19 report. No further remediation possible short of a disruptive history rewrite.
- **`screenprops` — client-side-only ownership enforcement on `projects`.** No commits since 2026-07-10; the live-Supabase RLS check flagged on 2026-08-19 is still unconfirmed.
- **`where-it-counts` — latent `{@html}` usage in `Scrollytelling.svelte:51`.** Unchanged, not exploitable today (hardcoded literals).
- **`Calculator2.0` — no SRI on CDN-loaded D3/Supabase-js scripts.** Unchanged.

### ℹ️ Out-of-scope but worth flagging: `tamagotchi-game`

`tamagotchi-game` had no new commits since the last scan checkpoint (`a322c7f5`, 2026-04-22), so it was correctly skipped under this report's diff-based protocol. However, the dotfiles repo's separate monthly code-quality audit (`reports/audit-2026-08-27.md`, run the same week) inspected it anyway and found a real, still-open security issue worth carrying into this series so it isn't lost between the two report tracks:

- **MEDIUM — unvalidated localStorage deserialization → path traversal.** `src/app/services/pet-state.service.ts:148-172` parses `petType`/`baseState` from `localStorage` without validating against known values. `petType` flows unsanitized into `getCurrentSpritePath()` to build `assets/pets/${petType}/${state}.png` — a tampered value (e.g. `../../evil`) is a path-traversal vector. Fix: validate `petType` against the `PET_OPTIONS` id list and `baseState` against valid literals before assigning; fall back to defaults on invalid values.
- **LOW — unbounded `petName` from localStorage**, same file, lines 156-158. Fix: cap to 32 chars and re-validate against the setup-flow `nameRegex`.

Recommend fixing on the next commit to that repo, independent of whether it trips this scan's checkpoint diff.

---

## New Issues Found This Run

None beyond the `neo-control` dependency vulnerabilities above (already known to the dotfiles monthly-audit series, newly confirmed here against the lockfile with a security lens).

---

## Repos Confirmed Clean

- **`dotfiles`** — HEAD only advanced via report-file additions (`audit-2026-08-26.md`, `audit-2026-08-27.md`, this file's predecessor). No secrets, no unsafe shell patterns, no plaintext credentials in the new report content.
- **`sudoku`** — `v2-redesign` merge (self-hosted Fraunces/Nunito Sans, a11y fixes for reduced-motion and toggle interactions, production-domain URL updates). Reviewed `package.json`/`package-lock.json` (react 19.2.7, vite 7.3.6, postcss 8.5.25, nanoid 3.3.17, esbuild 0.28.1 — all newer than the flagged neo-control versions), searched for `dangerouslySetInnerHTML`, hardcoded secrets/keys, and `.env`-style leaks: none found. Self-hosting fonts is a net-positive — one fewer third-party request on every page load. Note: this repo has no dedicated `npm audit`-based scan in the audit series, so treat the lockfile check above as a spot-check rather than exhaustive; worth a full `npm audit` run directly against the repo when convenient.

## Repos Unchanged Since Last Scan (skipped)

`where-it-counts`, `true-cost-of-car-ownership`, `amanda-repository`, `Calculator2.0`, `screenprops`, `amandarae220` (profile), `doteon`, `scamlessgames`, `tamagotchi-game`, `DungeonsAndDragons`, `interactiveResume`, `habitTracker` — identical HEAD commit to the 2026-08-19 checkpoint, no new commits to review.

---

## Top Actions (ranked)

1. **[SECURITY, neo-control] Run `npm i react-router-dom@7.18.2 && npm audit fix`.** Closes the CSRF bypass (the only vuln with a direct exploit path) plus the four transitive DoS/traversal advisories in one pass. Nothing else in the repo needs a security fix this run.
2. **[SECURITY, tamagotchi-game] Validate `petType`/`baseState` read from localStorage before building asset paths.** Not required by this run's protocol (no new commits) but genuinely open and low-effort to fix whenever that repo is next touched.
3. **[SECURITY, screenprops] Still needs a live-dashboard check that Supabase RLS is actually enabled on `projects`.** Open since 2026-08-19; no code-level fix will resolve this — it can only be confirmed outside the repo.
4. No other action items. The one remaining CRITICAL (`amanda-repository`'s burned credential) remains a historical-exposure item with no further remediation available.
