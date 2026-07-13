# Security Scan — 2026-07-13

## Scope & Methodology

Incremental run against the checkpoint in [`security-scan-2026-07-04.md`](security-scan-2026-07-04.md). Each repo's current default-branch HEAD was diffed against its checkpoint SHA; only repos with new commits since 2026-07-04 were deep-scanned. Repos with no new commits were skipped per the recurring-scan protocol (their 2026-07-04 findings still stand — see that report).

## Repos With Activity Since Last Scan — Checkpoint for Next Run

| Repo | Prior SHA (2026-07-04) | Current SHA | Date | Owner |
|---|---|---|---|---|
| screenprops | `19fe372` | `fb5662a` | 2026-07-10 | amandarae220 |
| sudoku | `a833819` | `b0788f2` | 2026-07-10 | amandarae220 |
| where-it-counts | `218684e` | `32084ee` | 2026-07-09 | amandarae220 |
| amanda-repository | `131a77c` | `3dddcfd` | 2026-07-09 | amandarae220 |
| neo-control | `144f5d2` | `97e4243` | 2026-07-08 | amandarae220 |
| Calculator2.0 | `3a4bcf9` | `93e0ae5` | 2026-07-07 | amandarae220 |
| dotfiles | `e763a29` | `90b9cb1` | 2026-07-07 | amandarae220 |

7 of 15 accessible repos had new commits and were deep-scanned. The other 8 (true-cost-of-car-ownership, amandarae220 profile, doteon, scamlessgames, DungeonsAndDragons, tamagotchi-game, sudoku-predecessor state, interactiveResume, habitTracker) are unchanged since 2026-07-04 and were skipped — see that report for their standing findings.

Findings this run: **0 new critical, 1 high (carried forward, unfixed), 1 medium (carried forward, unchanged), 3 low/informational.** Two prior findings (1 critical, 1 high) were **remediated** by work in this window.

---

## ✅ Remediated Since Last Scan

**`neo-control` — critical exposed-credential finding is fixed.**
The 2026-07-04 report flagged a live plaintext `VITE_ADMIN_PASS` value committed in `CONTEXT.md`. Commits `6819dd2` ("security fixes") and `fa0f370` ("removing refs to admin password") stripped the literal value and then the env-var reference entirely; commit `ceef7ec` ("manual auth updates") completed a migration to real Supabase email/password auth (`supabase.auth.signInWithPassword()` in `AdminPage.tsx`), replacing the old client-side string-compare gate. `npm audit` is now clean (0 vulnerabilities) — the previously-flagged `react-router-dom`/`vite` CVEs were also resolved along the way (`ccb1e49`, "npm audit fix").
- Residual note (informational only): the old password value (`checkadmininsights`) remains permanently retrievable via `git log --all -p` on this repo. It's no longer a live credential — the front-end gate it protected doesn't exist anymore — but rotate it anywhere it may have been reused, same as the already-noted `amanda-repository` burned password.

**`sudoku` — high-severity dependency-toolchain finding is fixed.**
The prior report flagged 57 vulnerabilities (2 critical, 24 high) in the CRA/`react-scripts` build toolchain and recommended migrating off it. The repo has since been fully migrated to Vite (`55fc1ac` through `b0788f2`): CRA files deleted, build output untracked and gitignored, tests preserved and expanded (`SudokuBoard.test.tsx`, `sudoku.test.ts` both grew). `npm audit` now reports **0 vulnerabilities**.

---

## 🔴 High (carried forward, still unfixed)

- **`Calculator2.0`**: `admin.html:551-552` — the stored-XSS finding from 2026-07-04 is still present, unchanged. This window's commits (`cfbe568`, `6722a74`) only touched `CLAUDE.md`/`README.md`; the vulnerable code wasn't part of this work. `device`/`browser` values from the anon-writable `calculator_events` table are still concatenated directly into `innerHTML` for `<option>` tags. Fix unchanged from prior recommendation: use `textContent`/`createElement`, and constrain `device`/`browser` with a DB-level allow-list/CHECK constraint.

## 🟡 Medium (carried forward, unchanged)

- **`screenprops`**: The prior finding about `projects`-table ownership scoping (`.eq("user_id", user.id)` enforced only in client-side Supabase queries) is still the pattern in use — confirmed present in `app/tiktok/dm/page.tsx`, `app/tiktok/video/page.tsx`, `app/twitter/thread/page.tsx`. This window's changes (new `/pricing` page, `proxy.ts` public-route list, nav updates) don't touch this surface and don't add new risk. Still recommend verifying RLS is actually enabled on `projects` in the Supabase dashboard rather than relying on the client-supplied filter.

## 🟢 Low / Informational

- **`amanda-repository`**: `npm audit` (dev deps only) shows 3 low-severity advisories — `@babel/core` arbitrary file read via `sourceMappingURL` (fix requires downgrading `@angular/build`, a breaking change) and `esbuild` arbitrary file read on Windows dev server (fix available, non-breaking). Both are dev/build-time only, not shipped to production. No action required beyond routine `npm audit fix` when convenient.
- **`where-it-counts`**: `npm audit` (dev deps only) shows 3 low-severity advisories via `@sveltejs/kit`'s `cookie` dependency (fix requires downgrading to `@sveltejs/kit@0.0.30`, not viable). Also: the previously-flagged `Scrollytelling.svelte:51` `{@html step.text}` latent-XSS note still applies — content remains hardcoded/static, so still not exploitable today, but unchanged from the prior recommendation to switch to plain interpolation.
- **`neo-control`**: no new dependency or secret issues found in the gameplay-content changes (`GameCanvas.tsx`, wave transmissions, sprite art) this window.

---

## Repos Skipped (no commits since 2026-07-04)

true-cost-of-car-ownership, amandarae220 (profile), doteon, scamlessgames, DungeonsAndDragons, tamagotchi-game, interactiveResume, habitTracker. Their standing findings are unchanged — see [`security-scan-2026-07-04.md`](security-scan-2026-07-04.md).

---

## Top Actions (ranked)

1. **Fix the stored-XSS path in `Calculator2.0`'s `admin.html`** — still open since 2026-07-04, no code change has touched it this window.
2. **Verify Supabase RLS on `screenprops`'s `projects` table** in the dashboard — client-side `.eq("user_id", ...)` is not itself an authorization boundary.
3. No action needed on `neo-control` or `sudoku` — both prior high/critical findings are confirmed remediated.
