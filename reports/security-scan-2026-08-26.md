# Security Scan — 2026-08-26

## Scope & Methodology

Incremental scan against the checkpoint in `security-scan-2026-08-19.md`. Each of the 15 accessible repos' current HEAD commit was compared to that report's checkpoint table; only repos with new commits since the checkpoint were deep-scanned. Repos with an unchanged HEAD were skipped per the checkpoint protocol.

## Repos Scanned — Updated Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Status this run |
|---|---|---|---|---|
| dotfiles | `24c0eccf` | 2026-08-26 | amandarae220 | Checked — only change is a report file addition (this repo's own audit workflow), no code touched — clean |
| sudoku | `69957efd` | 2026-08-26 | amandarae220 | Scanned — clean |
| neo-control | `8c16c4a9` | 2026-08-26 | amandarae220 | Scanned — clean |
| amanda-repository | `01b0786` | 2026-08-13 | amandarae220 | No change since last scan — skipped |
| Calculator2.0 | `d68de4a` | 2026-08-13 | amandarae220 | No change since last scan — skipped |
| amandarae220 (profile) | `24d9a2c` | 2026-07-28 | amandarae220 | No change since last scan — skipped |
| screenprops | `fb5662a` | 2026-07-10 | amandarae220 | No change since last scan — skipped |
| where-it-counts | `32084ee` | 2026-07-09 | amandarae220 | No change since last scan — skipped |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | amandarae220 | No change since last scan — skipped |
| doteon | `5413b63` | 2026-05-29 | amandarae220 | No change since last scan — skipped |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ | No change since last scan — skipped |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 | No change since last scan — skipped |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 | No change since last scan — skipped |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 | No change since last scan — skipped |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 | No change since last scan — skipped |

**3 of 15 repos updated since 2026-08-19 and deep-scanned. 12 unchanged and skipped.**

---

## Security Issues Found This Run

None. All three updated repos came back clean.

- **`sudoku`** — merged PR #5 "V2 redesign" plus three follow-up commits (interaction tests, `prefers-reduced-motion` support, accessibility-audit fixes). All changes are test code, scoped CSS, and JSX-rendered UI state (`role="status"` live region, focus-visible outline). No `dangerouslySetInnerHTML`/`innerHTML`/`eval` anywhere in the repo (repo-wide search, 0 hits). No dependency changes — `package.json` at HEAD is unchanged (React 19, Vite 7, Vitest 3, `gh-pages` 6); no CRA/`react-scripts` reintroduced. No secrets in the diffs.
- **`neo-control`** — merged PR #29 "Feature/updated storyline" plus a docking-animation commit and a spelling fix. Only `src/game/GameCanvas.tsx` changed — new scrollbar/mouse-wheel handling for the mission-brief panel and a wave-2 docking animation, all canvas draw calls (`fillText`/`fillRect`), not DOM string injection. No touches to `auth.ts`, the admin dashboard, or session-submission logic — the anon-INSERT/authenticated-SELECT RLS boundary is untouched. No `VITE_ADMIN_PASS` or client-side password gate reintroduced. No `package.json` changes.
- **`dotfiles`** — the only commit since the checkpoint added `reports/audit-2026-08-26.md` (an unrelated monthly audit report). No shell scripts, hooks, or install code touched.

## Still Open (carried forward, unchanged — not re-verified this run since these repos had no new commits)

- **`amanda-repository` — CRITICAL, burned credential in git history.** The 2026-06-14 plaintext admin password and its two unsalted SHA-256 hashes remain permanently retrievable via `git log --all -p`. Not fixable by further code changes; treat as burned and rotate anywhere it may have been reused. No repo activity this window.
- **`screenprops` — MEDIUM, client-side-only ownership enforcement on `projects`.** Dashboard read and delete action still scope to `user_id` only via a client-supplied Supabase filter using the anon key; no server-side route handlers or RLS/schema SQL in-repo to confirm enforcement lives in the database. **Action still needed: confirm RLS is actually enabled and correctly scoped on the live Supabase `projects` table** — unverifiable from source alone. No repo activity this window.
- **`where-it-counts` — LOW, latent `{@html}` usage.** `Scrollytelling.svelte:51` still renders `step.text` via `{@html}`; values remain hardcoded literal strings today, not exploitable, but would become real XSS if step text is ever sourced from a CMS/API without sanitization. No repo activity this window.
- **`Calculator2.0` — LOW/informational, no SRI on CDN scripts.** D3 and Supabase-js still loaded from CDN in `index.html`/`admin.html` without `integrity`/`crossorigin` attributes. No repo activity this window.

## Repos Confirmed Clean (this run)

`dotfiles`, `sudoku`, `neo-control`.

## Repos Unchanged Since Last Scan (skipped)

`amanda-repository`, `Calculator2.0`, `amandarae220` (profile), `screenprops`, `where-it-counts`, `true-cost-of-car-ownership`, `doteon`, `scamlessgames`, `tamagotchi-game`, `DungeonsAndDragons`, `interactiveResume`, `habitTracker` — identical HEAD commit to the 2026-08-19 checkpoint, no new commits to review.

---

## Top Actions (ranked)

1. **Verify Supabase RLS on `screenprops`'s `projects` table in the live dashboard.** Still the only open item requiring action outside the codebase.
2. No new action items from this run — all three updated repos are clean. The one remaining CRITICAL (`amanda-repository`'s burned credential) is a historical-exposure item with no further remediation short of a disruptive history rewrite, and stays open only as a "confirm not reused elsewhere" reminder.
