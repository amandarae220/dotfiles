# Security Scan — 2026-09-16

## Scope & Methodology

Incremental scan against the baseline established in `security-scan-2026-08-19.md`. Each of the 15 accessible repos' current HEAD commit was compared to that report's checkpoint table; only repos with new commits since the checkpoint were deep-scanned for secrets, dependency vulnerabilities, and code-level security/quality concerns. Repos with an unchanged HEAD were skipped per the checkpoint protocol.

## Repos Scanned — Updated Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Status this run |
|---|---|---|---|---|
| neo-control | `8c16c4a9` | 2026-08-26 | amandarae220 | Scanned — no new secrets/vulns in code; 5 HIGH dependency advisories open (see below) |
| dotfiles | `a28246c3` | 2026-08-27 | amandarae220 | Scanned — report-only commits, clean |
| sudoku | `69957efd` | 2026-08-26 | amandarae220 | Scanned — a11y/theming-only change, clean |
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

---

## Findings by Severity

### 🔴 High

- **`neo-control` — 5 HIGH `npm audit` advisories, most notably a CSRF bypass.** `react-router`/`react-router-dom` (GHSA-qwww-vcr4-c8h2, CSRF bypass in RSC mode, affects `>=7.12.0 <7.18.2`) is one patch version behind. Also flagged: `js-yaml` (quadratic-CPU DoS, CVE-2026-59870), `postcss` (path traversal via `sourceMappingURL`, GHSA-fxqj-rqcc-2cmp), `brace-expansion` (exponential-expansion DoS, GHSA-3jxr-9vmj-r5cp), `nanoid` (infinite loop on negative size, GHSA-28wg-ghj8-5hjv). None of this window's actual code changes (a narrative/docking-sequence feature + a scrollable-briefing UI, reviewed in full) touch dependencies or introduce new risk — this is a manifest/lockfile drift issue, not a code regression. **Fix:** `npm i react-router-dom@7.18.2 && npm audit fix` in `neo-control`.

### Carried Forward (unchanged repos — not re-verified this run, still open per last scan)

- **`amanda-repository` — CRITICAL, burned credential in git history.** The 2026-06-14 plaintext admin password and its two unsalted SHA-256 hashes remain permanently retrievable via `git log --all -p`. No history rewrite has occurred. Not fixable by further code changes; stays open only as a "confirm not reused elsewhere" reminder.
- **`screenprops` — MEDIUM, client-side-only ownership enforcement on `projects`.** Still unverified whether Supabase RLS is actually enabled on the live `projects` table — can't be confirmed from source alone.
- **`where-it-counts` — LOW, latent `{@html}` usage** in `Scrollytelling.svelte:51` (hardcoded literal strings today, would become exploitable if content is ever sourced dynamically).
- **`Calculator2.0` — LOW/informational, no SRI on CDN scripts** (D3, Supabase-js loaded without `integrity`/`crossorigin`).

## New Issues Found This Run

None in the diffs themselves. The one actionable item (`neo-control` dependency advisories) is a newly-published-CVE / lockfile-drift issue, not something introduced by this window's commits.

---

## Repos Confirmed Clean

- **`neo-control`** — Reviewed the full diff for PR #29 ("Feature/updated storyline": wave-2 Xylon-freighter docking sequence, draggable/wheel-scrollable briefing text). No secrets, no unsafe DOM/eval usage, no new attack surface. Repo-wide search confirms `VITE_ADMIN_PASS` has not reappeared — the earlier CRITICAL (client-side admin gate) stays resolved.
- **`sudoku`** — PR #5 ("V2 redesign" follow-up) is accessibility/theming work only: app-wide `prefers-reduced-motion` handling, a screen-reader live-region for the board self-check, an optional-chaining fix in the theme toggle, and new tests. No network calls, no secrets, no dynamic HTML injection. `package.json` dependencies (React 19, Vite 7, Vitest 3, gh-pages 6) are current majors.
- **`dotfiles`** — The only changes since the last checkpoint are three markdown files (`security-scan-2026-08-19.md`, `audit-2026-08-26.md`, `audit-2026-08-27.md`) added by a separate scheduled monthly-audit job. Both new audit reports were checked line-by-line for the same "credential echoed in a report" mistake fixed here in July — confirmed clean, no plaintext secrets or tokens in either file. No script/code changes in this window.

## Repos Unchanged Since Last Scan (skipped)

`where-it-counts`, `true-cost-of-car-ownership`, `amanda-repository`, `Calculator2.0`, `screenprops`, `amandarae220` (profile), `doteon`, `scamlessgames`, `tamagotchi-game`, `DungeonsAndDragons`, `interactiveResume`, `habitTracker` — identical HEAD commit to the 2026-08-19 checkpoint, no new commits to review.

---

## Top Actions (ranked)

1. **Patch `neo-control` dependencies.** `npm i react-router-dom@7.18.2 && npm audit fix` clears the CSRF bypass plus the other 4 HIGH advisories (`js-yaml`, `postcss`, `brace-expansion`, `nanoid`). This is the only code-actionable finding this run.
2. **Verify Supabase RLS on `screenprops`'s `projects` table in the live dashboard** (carried forward, repo unchanged — still needs a check outside the codebase).
3. No other action items. `amanda-repository`'s burned credential remains a historical-exposure item with no further remediation available short of a disruptive history rewrite.
