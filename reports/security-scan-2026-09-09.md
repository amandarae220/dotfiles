# Security Scan — 2026-09-09

## Scope & Methodology

Incremental scan against the baseline established in `security-scan-2026-08-19.md`. Each of the 15 accessible repos' current HEAD commit was compared to that report's checkpoint table; only repos with new commits since the checkpoint were deep-scanned. Repos with an unchanged HEAD were skipped per the checkpoint protocol.

## Repos Scanned — Updated Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Status this run |
|---|---|---|---|---|
| dotfiles | `a28246c3` | 2026-08-27 | amandarae220 | Scanned — report-only commits, clean |
| neo-control | `8c16c4a9` | 2026-08-26 | amandarae220 | Scanned — clean |
| sudoku | `69957efd` | 2026-08-26 | amandarae220 | Scanned — clean |
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

**3 of 15 repos updated since 2026-08-19 and deep-scanned. 12 unchanged and skipped.**

Note: the `dotfiles` repo's only new commits since the checkpoint (`24c0ecc`, `a28246c`) are the automated `reports/audit-2026-08-26.md` and `reports/audit-2026-08-27.md` monthly-audit report files — a separate scheduled task, not a security scan. Each commit touches only its own new report file under `reports/`; no application code, scripts, or config changed. No overlap with this scan's own checkpoint file.

---

## New Issues Found This Run

None. Reviewed every commit landed in the three updated repos since their last checkpoint:

- **`neo-control`** (`1a7582c`, `ec3c5fd` — copy fix + wave-2 docking animation): pure canvas rendering and pointer/wheel event wiring in `src/game/GameCanvas.tsx` for a new draggable scrollbar and a Xylon-freighter docking sequence. No new dependencies, no `innerHTML`/`eval`/dynamic script injection, no new persistence or network calls. Event listeners are added and torn down symmetrically in the cleanup path.
- **`sudoku`** (`df77236b`, `2986058a`, `f93c8e6` — interaction tests + reduced-motion + a11y fixes): test additions, a global `prefers-reduced-motion` CSS block, an optional-chaining guard on `window.matchMedia(...)?.matches`, and an `aria-live` status region for self-check results. No new dependencies, no unvalidated data flowing into the DOM or storage.
- **`dotfiles`**: report-file-only commits, no code touched.

No secrets, credentials, or tokens introduced in any diff. No `package.json`/lockfile changes in any of the three repos this run, so no new dependency surface to evaluate.

## Still Open (carried forward, unchanged)

These repos had no new commits this run, so they were not re-scanned; their previously reported findings still stand as of the last time each was actually scanned.

- **`amanda-repository` — CRITICAL, burned credential in git history.** Unchanged since 2026-08-19. The 2026-06-14 plaintext admin password (commit `875772e`) and its two unsalted SHA-256 hashes remain permanently retrievable via `git log --all -p`. Not fixable by further code changes; treat as burned and rotate anywhere it may have been reused.
- **`screenprops` — MEDIUM, client-side-only ownership enforcement on `projects`.** Unchanged since 2026-08-19. Action still needed: confirm RLS is actually enabled and correctly scoped on the live Supabase `projects` table — this can't be verified from source code alone.
- **`where-it-counts` — LOW, latent `{@html}` usage.** Unchanged since 2026-07-09 checkpoint. `Scrollytelling.svelte:51` still renders `step.text` via `{@html}` with hardcoded literal strings — not exploitable today, but would become real XSS if step text is ever sourced from a CMS/API without sanitization.
- **`Calculator2.0` — LOW/informational, no SRI on CDN scripts.** Unchanged since 2026-08-13 checkpoint. D3 and Supabase-js are still loaded from CDN in `index.html`/`admin.html` without `integrity`/`crossorigin` attributes.

---

## Repos Confirmed Clean

- **`dotfiles`** — new commits are report additions only.
- **`neo-control`** — new canvas/UX code reviewed line-by-line; no security-relevant findings.
- **`sudoku`** — new a11y/test/CSS code reviewed line-by-line; no security-relevant findings.

## Repos Unchanged Since Last Scan (skipped)

`where-it-counts`, `true-cost-of-car-ownership`, `amanda-repository`, `Calculator2.0`, `screenprops`, `amandarae220` (profile), `doteon`, `scamlessgames`, `tamagotchi-game`, `DungeonsAndDragons`, `interactiveResume`, `habitTracker` — identical HEAD commit to the 2026-08-19 checkpoint, no new commits to review.

---

## Top Actions (ranked)

1. **Verify Supabase RLS on `screenprops`'s `projects` table in the live dashboard.** Still the only open item requiring action outside the codebase.
2. No new action items from this run. The one remaining CRITICAL (`amanda-repository`'s burned credential) is a historical-exposure item with no further remediation available short of a disruptive history rewrite, and stays open only as a "confirm not reused elsewhere" reminder.
