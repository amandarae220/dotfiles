# Security Scan — 2026-09-20

## Scope & Methodology

Incremental scan against the checkpoint established in `security-scan-2026-09-16.md`. Each of the 15 accessible repos' current HEAD commit was compared to that report's checkpoint table. No repo (other than `dotfiles` itself, via the act of committing the prior report) has a new commit since 2026-09-16, so no deep scan was performed this run per the checkpoint protocol.

## Repos Scanned — Updated Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Status this run |
|---|---|---|---|---|
| dotfiles | `e057d3f2` | 2026-09-16 | amandarae220 | Only new commit is the prior scan report itself (`security-scan-2026-09-16.md`, added by the last run) — report-only, already reviewed, no code changed. No new scan needed. |
| neo-control | `8c16c4a9` | 2026-08-26 | amandarae220 | No change since last scan — skipped |
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

**0 of 15 repos had substantive changes since 2026-09-16. 14 unchanged; `dotfiles` advanced by one report-only commit (the last scan's own output), which does not require re-scanning.**

---

## Findings by Severity

No new findings this run — nothing was deep-scanned because nothing changed.

### Carried Forward (unchanged repos — not re-verified this run, still open per last scan)

- **`neo-control` — HIGH, 5 open `npm audit` advisories**, most notably a CSRF bypass in `react-router-dom` (GHSA-qwww-vcr4-c8h2, affects `>=7.12.0 <7.18.2`). Also `js-yaml` (CVE-2026-59870, quadratic-CPU DoS), `postcss` (GHSA-fxqj-rqcc-2cmp, path traversal), `brace-expansion` (GHSA-3jxr-9vmj-r5cp, exponential-expansion DoS), `nanoid` (GHSA-28wg-ghj8-5hjv, infinite loop). **Still unpatched** — no commits to this repo since it was first flagged. Fix: `npm i react-router-dom@7.18.2 && npm audit fix`.
- **`amanda-repository` — CRITICAL, burned credential in git history.** The 2026-06-14 plaintext admin password and its two unsalted SHA-256 hashes remain permanently retrievable via `git log --all -p`. Not fixable by further code changes; open only as a "confirm not reused elsewhere" reminder.
- **`screenprops` — MEDIUM, client-side-only ownership enforcement on `projects`.** Still unverified whether Supabase RLS is actually enabled on the live `projects` table — can't be confirmed from source alone.
- **`where-it-counts` — LOW, latent `{@html}` usage** in `Scrollytelling.svelte:51` (hardcoded literal strings today, would become exploitable if content is ever sourced dynamically).
- **`Calculator2.0` — LOW/informational, no SRI on CDN scripts** (D3, Supabase-js loaded without `integrity`/`crossorigin`).

## Repos Confirmed Clean

- **`dotfiles`** — the only change since 2026-09-16 is the addition of that same report file by the prior run. No script/code changes in this window.

## Repos Unchanged Since Last Scan (skipped)

`neo-control`, `sudoku`, `where-it-counts`, `true-cost-of-car-ownership`, `amanda-repository`, `Calculator2.0`, `screenprops`, `amandarae220` (profile), `doteon`, `scamlessgames`, `tamagotchi-game`, `DungeonsAndDragons`, `interactiveResume`, `habitTracker` — identical HEAD commit to the 2026-09-16 checkpoint, no new commits to review.

---

## Top Actions (ranked)

1. **Patch `neo-control` dependencies.** `npm i react-router-dom@7.18.2 && npm audit fix` clears the CSRF bypass plus the other 4 HIGH advisories. Still the only code-actionable item outstanding, unchanged from the last two runs.
2. **Verify Supabase RLS on `screenprops`'s `projects` table in the live dashboard** (carried forward, repo unchanged — still needs a check outside the codebase).
3. No other action items. `amanda-repository`'s burned credential remains a historical-exposure item with no further remediation available short of a disruptive history rewrite.
