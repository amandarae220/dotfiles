# Security Scan — 2026-08-19

## Scope & Methodology

Incremental scan against the baseline established in `security-scan-2026-07-04.md`. Each of the 15 accessible repos' current HEAD commit was compared to that report's checkpoint table; only repos with new commits since the checkpoint were deep-scanned. Repos with an unchanged HEAD were skipped per the checkpoint protocol.

## Repos Scanned — Updated Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Status this run |
|---|---|---|---|---|
| neo-control | `683fac28` | 2026-08-13 | amandarae220 | Scanned — all prior findings resolved |
| dotfiles | `9e31777` | 2026-07-30 | amandarae220 | Scanned — clean |
| where-it-counts | `32084ee` | 2026-07-09 | amandarae220 | Scanned — 1 latent low carried forward |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | amandarae220 | No change since last scan — skipped |
| amanda-repository | `01b0786` | 2026-08-13 | amandarae220 | Scanned — 1 burned-credential item carried forward |
| Calculator2.0 | `d68de4a` | 2026-08-13 | amandarae220 | Scanned — prior HIGH resolved |
| screenprops | `fb5662a` | 2026-07-10 | amandarae220 | Scanned — 1 medium carried forward |
| amandarae220 (profile) | `24d9a2c` | 2026-07-28 | amandarae220 | Scanned — clean |
| doteon | `5413b63` | 2026-05-29 | amandarae220 | No change since last scan — skipped |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ | No change since last scan — skipped |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 | No change since last scan — skipped |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 | No change since last scan — skipped |
| sudoku | `923a3c1` | 2026-08-10 | amandarae220 | Scanned — prior HIGH resolved |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 | No change since last scan — skipped |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 | No change since last scan — skipped |

**8 of 15 repos updated since 2026-07-04 and deep-scanned. 7 unchanged and skipped.**

---

## Resolved Since Last Scan ✅

- **`neo-control` — CRITICAL exposed admin passphrase: RESOLVED.** Commit `ceef7ece` replaced the client-side string-compare gate with real Supabase Auth (`signInWithPassword`); `fetchSessions()` now runs under the authenticated JWT instead of the anon key. `fa0f370c` stripped the literal `VITE_ADMIN_PASS` value from `CONTEXT.md`. Repo-wide search confirms zero remaining references.
- **`neo-control` — HIGH dependency CVEs (react-router-dom, vite): RESOLVED.** `react-router-dom` 7.14.2 → 7.18.1, `vite` 8.0.9 → 8.1.3 (`ccb1e499`, `6819dd2a`).
- **`neo-control` — MEDIUM `js-yaml`/`brace-expansion` DoS: RESOLVED.** Current lockfile: `js-yaml` 4.3.0, `brace-expansion` 1.1.14 — both past the flagged vulnerable ranges.
- **`Calculator2.0` — HIGH stored XSS in `admin.html`: RESOLVED.** Commit `e609f4a` replaced string-concatenated `innerHTML` for `device`/`browser` dropdown options with `document.createElement` + `.textContent`. Bonus: the same commit whitelists `event_type` against a known-values list before using it in a CSS class name, closing a secondary vector not in the original report.
- **`sudoku` — HIGH: 57 `npm audit` vulnerabilities in the CRA/`react-scripts` toolchain: RESOLVED.** Commit `55fc1ac` migrated the whole build off Create React App to Vite/Vitest, removing `react-scripts` and its entire vulnerable transitive tree. Current stack: Vite 7, Vitest 3, React 19 — no `react-scripts` in the dependency graph.
- **`dotfiles` — LOW: plaintext credential echoed in an old audit report: RESOLVED.** Commit `b14409e` redacted the password in both `reports/audit-2026-06-16.md` and `reports/security-scan-2026-07-04.md`. Newer reports added since contain no plaintext secrets.

## Still Open (carried forward, unchanged)

- **`amanda-repository` — CRITICAL, burned credential in git history.** The 2026-06-14 plaintext admin password (commit `875772e`) and its two unsalted SHA-256 hashes remain permanently retrievable via `git log --all -p`. No history rewrite has occurred (commit graph since the last scan is fully linear/normal merges — expected, since rewriting shared history is a deliberate, disruptive action). Not fixable by further code changes; treat as burned and rotate anywhere it may have been reused. No action needed unless that password is still live somewhere.
- **`screenprops` — MEDIUM, client-side-only ownership enforcement on `projects`.** Both the dashboard read (`app/dashboard/page.tsx:34-38`) and the delete action (`DashboardClient.tsx:41`) scope to `user_id` only via a client-supplied Supabase filter using the anon key. No server-side route handlers, no RLS/schema SQL files exist in-repo to confirm enforcement lives in the database. Two commits landed since the last scan (a pricing page, an animation/photosensitivity fix) but neither touched this path. **Action still needed: confirm RLS is actually enabled and correctly scoped on the live Supabase `projects` table** — this can't be verified from source code alone.
- **`where-it-counts` — LOW, latent `{@html}` usage.** `Scrollytelling.svelte:51` still renders `step.text` via `{@html}`. The Svelte 5 / Vite 8 upgrade (PR #8) didn't touch this line, and the values remain hardcoded literal strings — not exploitable today, but would become real XSS if step text is ever sourced from a CMS/API without sanitization.
- **`Calculator2.0` — LOW/informational, no SRI on CDN scripts.** D3 and Supabase-js are still loaded from CDN in `index.html`/`admin.html` without `integrity`/`crossorigin` attributes.

## New Issues Found This Run

None. No repo introduced a new security-relevant finding in this scan window.

---

## Repos Confirmed Clean

- **`dotfiles`** — no secrets, no unsafe shell patterns in `install.sh`, no hook scripts executing untrusted input.
- **`amandarae220` (profile)** — both commits since the last scan only edited the README (removed GitHub-stats badge images, reducing third-party endpoint exposure); no secrets, no new files.

## Repos Unchanged Since Last Scan (skipped)

`true-cost-of-car-ownership`, `doteon`, `scamlessgames`, `tamagotchi-game`, `DungeonsAndDragons`, `interactiveResume`, `habitTracker` — identical HEAD commit to the 2026-07-04 checkpoint, no new commits to review.

---

## Top Actions (ranked)

1. **Verify Supabase RLS on `screenprops`'s `projects` table in the live dashboard.** This is the only open item that requires action outside the codebase — client-side filtering is not a substitute for a database-level policy.
2. No other action items — all previously-flagged HIGH/CRITICAL/MEDIUM findings with a code-level fix have been resolved. The one remaining CRITICAL (`amanda-repository`'s burned credential) is a historical-exposure item with no further remediation available short of a disruptive history rewrite, and stays open only as a "confirm not reused elsewhere" reminder.
