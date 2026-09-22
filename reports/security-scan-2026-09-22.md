# Security Scan — 2026-09-22

## Scope & Methodology

Incremental scan against the baseline established in `security-scan-2026-09-21.md`. Each of the 15 accessible repos' current HEAD commit was compared to that report's checkpoint table; only repos with new commits since the checkpoint would be deep-scanned. No repo had new commits, so no deep scanning was performed this run per the checkpoint protocol.

## Repos Scanned — Checkpoint (unchanged from 2026-09-21)

| Repo | Last Commit | Date | Owner | Status this run |
|---|---|---|---|---|
| neo-control | `8c16c4a9` | 2026-08-26 | amandarae220 | No change since last scan — skipped |
| dotfiles | `eed44acf` | 2026-09-21 | amandarae220 | No dev change — only the 2026-09-21 report commit landed on `main` since; not re-scanned as code |
| sudoku | `69957efd` | 2026-08-26 | amandarae220 | No change since last scan — skipped |
| where-it-counts | `32084ee` | 2026-07-09 | amandarae220 | No change since last scan — skipped |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | amandarae220 | No change since last scan — skipped |
| amanda-repository | `01b0786` | 2026-08-13 | amandarae220 | No change since last scan — skipped |
| Calculator2.0 | `d68de4a` | 2026-08-13 | amandarae220 | No change since last scan — skipped |
| screenprops | `fb5662a` | 2026-07-10 | amandarae220 | No change since last scan — skipped |
| amandarae220 (profile) | `24d9a2c` | 2026-07-28 | amandarae220 | No change since last scan — skipped |
| doteon | `5413b63` | 2026-05-29 | amandarae220 | No change since last scan — skipped |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ | No change since last scan — skipped |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 | No change since last scan — skipped |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 | No change since last scan — skipped |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 | No change since last scan — skipped |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 | No change since last scan — skipped |

**0 of 15 repos updated with new development commits since 2026-09-21. No detailed scanning performed this run.**

---

## Findings by Severity

No new findings — no code changed. Nothing to re-verify this run.

### Carried Forward (open per last scan, not re-verified — still unresolved as of the last time each was checked)

- **`neo-control` — HIGH, 5 open `npm audit` advisories** (react-router-dom CSRF bypass GHSA-qwww-vcr4-c8h2, js-yaml quadratic-CPU DoS, postcss path traversal, brace-expansion DoS, nanoid infinite loop). Fix identified in the 2026-09-16 report (`npm i react-router-dom@7.18.2 && npm audit fix`) does not appear to have landed yet — repo HEAD is unchanged.
- **`amanda-repository` — CRITICAL, burned credential in git history.** Plaintext admin password + two unsalted SHA-256 hashes from 2026-06-14 remain retrievable via `git log --all -p`. No history rewrite has occurred. No further remediation available short of a disruptive history rewrite; stays open as a "confirm not reused elsewhere" reminder.
- **`screenprops` — MEDIUM, client-side-only ownership enforcement on `projects`.** Still unverified whether Supabase RLS is enabled on the live `projects` table — not confirmable from source alone.
- **`where-it-counts` — LOW, latent `{@html}` usage** in `Scrollytelling.svelte:51` (hardcoded literal strings today; would become exploitable if content is ever sourced dynamically).
- **`Calculator2.0` — LOW/informational, no SRI on CDN scripts** (D3, Supabase-js loaded without `integrity`/`crossorigin`).

## Repos Confirmed Clean

Not applicable this run — no repos required scanning.

## Repos Unchanged Since Last Scan (skipped)

All 15 repos: `neo-control`, `dotfiles`, `sudoku`, `where-it-counts`, `true-cost-of-car-ownership`, `amanda-repository`, `Calculator2.0`, `screenprops`, `amandarae220` (profile), `doteon`, `scamlessgames`, `tamagotchi-game`, `DungeonsAndDragons`, `interactiveResume`, `habitTracker` — identical HEAD commit to the 2026-09-21 checkpoint, no new development commits to review.

---

## Top Actions (ranked)

1. **Patch `neo-control` dependencies** — still outstanding from the last three scans. `npm i react-router-dom@7.18.2 && npm audit fix` clears the CSRF bypass plus the other 4 HIGH advisories.
2. **Verify Supabase RLS on `screenprops`'s `projects` table in the live dashboard** — carried forward, still needs a check outside the codebase.
3. No other action items. `amanda-repository`'s burned credential remains a historical-exposure item with no further remediation available short of a disruptive history rewrite.
