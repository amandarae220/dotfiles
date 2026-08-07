# Security Scan — 2026-08-07

## Scope & Methodology

This is an incremental scan. The checkpoint table in `reports/security-scan-2026-07-04.md` recorded the last-scanned commit SHA for all 15 accessible repos. Each repo's current HEAD was compared against that checkpoint; only repos with new commits since 2026-07-04 were deep-scanned. Repos with no new commits were skipped per the established methodology.

**8 of 15 repos had new commits and were deep-scanned:** dotfiles, where-it-counts, neo-control, amanda-repository, Calculator2.0, screenprops, amandarae220 (profile), sudoku.

**7 of 15 repos were unchanged since 2026-07-04 and were skipped:** true-cost-of-car-ownership, doteon, scamlessgames, DungeonsAndDragons, tamagotchi-game, interactiveResume, habitTracker.

Each scanned repo's diff (checkpoint SHA → current HEAD) was reviewed for: exposed secrets/credentials, XSS/injection sinks, dependency vulnerabilities, insecure transport, access-control regressions, and exposed/unauthenticated API surface. Where the 2026-07-04 report had open findings against a repo, those were explicitly re-verified against current HEAD.

## Repos Scanned This Run

| Repo | Previous Commit | New Commit | Date | What Changed |
|---|---|---|---|---|
| dotfiles | `e763a29` | `9e31777` | 2026-07-30 | CLAUDE.md/skill updates, audit report additions |
| where-it-counts | `218684e` | `32084ee` | 2026-07-09 | Svelte 5 / Vite 8 upgrade (PR #8) |
| neo-control | `144f5d2` | `97e4243` | 2026-07-08 | Auth rework + storyline feature (PR #26) |
| amanda-repository | `131a77c` | `d8e3777` | 2026-08-04 | Rehosted calculator/sudoku/dnd/resume sub-apps (PR #19) |
| Calculator2.0 | `3a4bcf9` | `a36134a` | 2026-07-30 | Admin XSS fix, event-type whitelisting (PR #12) |
| screenprops | `19fe372` | `fb5662a` | 2026-07-10 | Pricing page + animation/a11y fix |
| amandarae220 (profile) | `2bc6ffb` | `24d9a2c` | 2026-07-28 | README cosmetic edit |
| sudoku | `a833819` | `d295f2b` | 2026-08-03 | CRA → Vite migration (PR #2) |

## Repos Unchanged — Skipped

| Repo | Commit (unchanged since 07-04) | Date |
|---|---|---|
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 |
| doteon | `5413b63` | 2026-05-29 |
| scamlessgames | `5303ffc` | 2026-05-23 |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 |
| tamagotchi-game | `a322c7f` | 2026-04-22 |
| interactiveResume | `3e638ca` | 2024-07-28 |
| habitTracker | `5b4aef4` | 2024-03-09 |

**No new security issues in this run: 0 critical, 0 high, 1 medium (carried over, unresolved), 4 low/informational.**

---

## ✅ Prior Findings Resolved

**`neo-control` — CRITICAL exposed admin passphrase — RESOLVED**
The 2026-07-04 finding (live `VITE_ADMIN_PASS` committed in plaintext in `CONTEXT.md`, also inlined into the client bundle, gating an anon-key-readable `sessions` table) is fixed. PR #24 ("manual auth updates", commit `ceef7ece`) replaced the client-side string-compare with real `supabase.auth.signInWithPassword()` + session-based auth in `AdminPage.tsx`; a follow-up commit stripped all `VITE_ADMIN_PASS` references from `CONTEXT.md`. Confirmed via code search at HEAD: zero remaining references anywhere in the repo. Admin reads to the `sessions` table now ride an authenticated JWT, not the bare anon key. *Caveat: the actual RLS policy on the `sessions` table lives only in the Supabase dashboard, not in tracked source — worth a manual confirmation there, but nothing in-repo remains exploitable.*

**`Calculator2.0` — HIGH stored XSS in `admin.html` — RESOLVED**
The 2026-07-04 finding (attacker-controlled `device`/`browser` fields from the anon-writable `calculator_events` table concatenated into `innerHTML`) is fixed in commit `e609f4a`. The fix commit message explicitly names the attack it closes. All dropdown/feed rendering now uses `textContent`/`createElement`; a companion fix also whitelists `event_type` before using it in a CSS class name. Verified at HEAD — no remaining `innerHTML`/`bypassSecurityTrustHtml` sinks fed by Supabase-sourced strings.

**`sudoku` — HIGH dependency vulnerabilities (57 advisories, CRA/react-scripts toolchain) — RESOLVED**
The 2026-07-04 finding is resolved, but not by the commit its own PR title claims. The actual fix was an earlier, separate Vite migration (commits `bf9d20a7`, `55fc1ac8`, `fc2733dc`) that deleted `react-scripts`/CRA outright in favor of Vite 7 + TypeScript 5.7 + Vitest 3 — confirmed zero `react-scripts` dependency at HEAD. The commit literally titled "npm audit fix" (`0096385a`) only bumped two transitive dev-deps 14 lines total; it did essentially nothing. **Recommend running a fresh `npm audit` against the new Vite-based lockfile to confirm a clean bill of health**, since none was run as part of this scan.

---

## 🟡 Medium — Still Open (unchanged from 2026-07-04, no new commits touched it)

- **`screenprops`**: Ownership scoping on the `projects` table is enforced only in client-side Supabase queries (`.eq("user_id", user.id)`) with no server-side route handlers or RLS policy visible in-repo. Not touched by this run's diff (pricing page + animation fix only) — remains unverifiable from source alone. **Action still needed: confirm RLS is actually enabled and correctly scoped on `projects` in the live Supabase dashboard.**

## 🟢 Low / Informational (new this run)

- **`dotfiles`**: `awesome-skills-reference.md` (added this cycle) documents a skill-install pattern that pipes third-party skill content (`curl officialskills.sh/... | base64 -d > ~/.claude/skills/...`) straight to disk with no integrity/provenance check or review step. Not an auto-run hook, so nothing executes today — but it normalizes installing unreviewed content into the global skill directory. Suggest adding a "review before writing" line to the doc.
- **`amanda-repository`**: The rehosted `calculator-v2/.github/workflows/deploy.yml` was vendored in under `public/` (inert there — Actions only reads root-level `.github/workflows/`), but it references a different repo's deploy target and a write-scoped `secrets.GITHUB_TOKEN`. Low risk today; would become a real issue if ever relocated to repo root.
- **`amanda-repository`**: CDN scripts (`d3js.org`, `cdn.jsdelivr.net/npm/@supabase/supabase-js`, Google Fonts) across the three rehosted sub-apps, including `admin.html` (which holds an authenticated Supabase session), load without Subresource Integrity hashes.
- **`sudoku`**: PR #2's "npm audit fix" commit title is misleading — the real remediation happened weeks earlier via the unrelated Vite migration. Documentation/process note only, not a code issue.

---

## Repos With No Issues Found

- **where-it-counts** — Svelte 5 / Vite 8 upgrade reviewed in full (151 locked packages, all from the legitimate npm registry, no typosquats). No `{@html}`/`innerHTML`, no `http://` links, no CDN scripts, no secrets. Compiler-forced a11y fixes only.
- **neo-control** — beyond the resolved critical finding above, storyline/gameplay commits and a routine `npm audit fix` dependency bump introduced no new issues.
- **amanda-repository** — rehost work vendored 4 static sub-apps via safe `express.static` routes (no path traversal). Calculator2.0's Supabase config/RLS carried over correctly hardened; no plaintext secrets, no service-role keys.
- **Calculator2.0** — beyond the resolved XSS above, only doc/accessibility changes in this range.
- **screenprops** — this run's diff (pricing page, animation fix) is unrelated to security; no new issues introduced.
- **amandarae220 (profile)** — cosmetic README edit only, no workflows, no secrets.
- **sudoku** — beyond the resolved dependency finding above, no new XSS sinks, no secrets, no insecure transport in the Vite migration.

---

## Top Actions (ranked)

1. **Confirm RLS on `screenprops`'s `projects` table in the live Supabase dashboard** — this is the one open item carried over from the last scan; still can't be verified from source.
2. **Run a fresh `npm audit` on `sudoku`'s new Vite-based lockfile** — the CRA-era vulnerabilities are gone via migration, but no audit has confirmed a clean result on the new toolchain.
3. Add a review/diff step to `dotfiles/awesome-skills-reference.md`'s skill-install instructions before third-party skill content is written to `~/.claude/skills/`.
4. Add SRI hashes to the CDN scripts in `amanda-repository`'s rehosted `calculator-v2/admin.html` (authenticated-session page) — same class of fix already recommended for the original Calculator2.0 repo.
5. No urgent action needed on the two resolved critical/high findings (`neo-control`, `Calculator2.0`) beyond the RLS/Supabase-dashboard confirmations noted above — both are fixed in source.

---

## Checkpoint for Next Run

| Repo | Last Commit | Date | Owner |
|---|---|---|---|
| dotfiles | `9e31777` | 2026-07-30 | amandarae220 |
| where-it-counts | `32084ee` | 2026-07-09 | amandarae220 |
| neo-control | `97e4243` | 2026-07-08 | amandarae220 |
| amanda-repository | `d8e3777` | 2026-08-04 | amandarae220 |
| Calculator2.0 | `a36134a` | 2026-07-30 | amandarae220 |
| screenprops | `fb5662a` | 2026-07-10 | amandarae220 |
| amandarae220 (profile) | `24d9a2c` | 2026-07-28 | amandarae220 |
| doteon | `5413b63` | 2026-05-29 | amandarae220 |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 |
| sudoku | `d295f2b` | 2026-08-03 | amandarae220 |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | amandarae220 |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 |
