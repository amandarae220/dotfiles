# Security Scan — 2026-09-01

## Scope & Methodology

Incremental scan against the baseline established in `security-scan-2026-08-19.md`. Each of the 15 accessible repos' current HEAD commit was compared to that report's checkpoint table; only repos with new commits since the checkpoint were deep-scanned (secrets/credentials, injection risks, dependency vulnerabilities, code-level security regressions). Repos with an unchanged HEAD were skipped per the checkpoint protocol.

## Repos Scanned — Updated Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Status this run |
|---|---|---|---|---|
| neo-control | `8c16c4a9` | 2026-08-26 | amandarae220 | Scanned — dependency findings (see below) |
| dotfiles | `a28246c3` | 2026-08-27 | amandarae220 | Scanned — clean |
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

---

## New Issues Found This Run

### `neo-control` — dependency vulnerabilities (5 advisories, transitive/build-tooling deps)

Code changes since the checkpoint (PR #29 "Feature/updated storyline": briefing-text drag-scrollbar, mouse-wheel scroll, wave-2 dock-target rename) were reviewed and are clean — no new DOM sinks (`innerHTML`/`eval`), no injection risk, no secrets. However, the current lockfile carries five packages with published HIGH-severity advisories:

| Package | Installed | Advisory | Fixed in | Reachability |
|---|---|---|---|---|
| `react-router` / `react-router-dom` | 7.18.1 | GHSA-qwww-vcr4-c8h2 — CSRF bypass in unstable RSC mode | 7.18.2 | **Effectively none** — this is a client-routed Vite SPA, not using React Server Components |
| `js-yaml` | 4.3.0 | GHSA-5p4m-2wfm-xmqj (CVE-2026-59870) — quadratic-CPU DoS parsing `!!omap` YAML | 4.3.1 | Low — transitive build-tool dep, not parsing user-supplied YAML at runtime |
| `postcss` | 8.5.16 | GHSA-fxqj-rqcc-2cmp — arbitrary `.map` file read via `sourceMappingURL` when `from` is unset | 8.5.23 | Low — build-time only, processes the app's own CSS |
| `brace-expansion` | 1.1.14 | GHSA-3jxr-9vmj-r5cp — exponential-time DoS on crafted `{}` patterns | 1.1.16 | Low — transitive glob dependency, not fed untrusted input |
| `nanoid` | 3.3.15 | GHSA-28wg-ghj8-5hjv — infinite loop when called with a negative `size` | 3.3.16 | Low — no app code calls `nanoid`/`customAlphabet` with a variable size |

None of these are reachable via player-facing input in the shipped game — all five are dev/build-tooling transitive dependencies or (for react-router) an unused code path. Still, each fix is a patch/minor bump away: `npm update react-router-dom js-yaml postcss brace-expansion nanoid && npm audit fix`. These same five were independently surfaced in the unrelated monthly-audit run (`reports/audit-2026-08-26.md`, 2026-08-26) — cross-referenced here because neo-control has commits since the last security-scan checkpoint and dependency posture is in this scan's scope regardless of which report noticed it first.

### `sudoku` — clean

Changes since the checkpoint (PR #5 "V2 redesign": theme-toggle `matchMedia` null-safety fix, `sr-only` live-region announcements for the board's self-check, app-wide `prefers-reduced-motion` handling, new tests) are accessibility/robustness work with no security surface. Dependency check: `postcss@8.5.25` and `nanoid@3.3.17` are already past the vulnerable versions flagged in neo-control above — no action needed here.

### `dotfiles` — clean

The only new commits are two `reports/audit-*.md` additions from the separate monthly-audit routine (2026-08-26, 2026-08-27). Checked both for the plaintext-credential leak pattern that hit an old audit report in 2026-06-16 — not present here; no secrets in either file.

---

## Still Open (carried forward, unchanged this run — no new commits in these repos to re-verify)

- **`amanda-repository` — CRITICAL, burned credential in git history.** The 2026-06-14 plaintext admin password (commit `875772e`) and its two unsalted SHA-256 hashes remain permanently retrievable via `git log --all -p`. Not fixable by further code changes; treat as burned and rotate anywhere it may have been reused.
- **`screenprops` — MEDIUM, client-side-only ownership enforcement on `projects`.** Dashboard read and delete both scope to `user_id` via a client-supplied Supabase filter using the anon key; no RLS/schema SQL in-repo to confirm server-side enforcement. **Action still needed: confirm RLS is enabled and correctly scoped on the live Supabase `projects` table.**
- **`where-it-counts` — LOW, latent `{@html}` usage.** `Scrollytelling.svelte:51` renders `step.text` via `{@html}`; values are hardcoded literals today, not exploitable, but would become real XSS if step text is ever sourced from a CMS/API without sanitization.
- **`Calculator2.0` — LOW/informational, no SRI on CDN scripts.** D3 and Supabase-js load from CDN in `index.html`/`admin.html` without `integrity`/`crossorigin` attributes.

## Resolved Since Last Scan

None — no fixes landed this cycle for prior open items.

## Repos Confirmed Clean

- **`neo-control`** — no secrets, no injection risk in this run's code changes (dependency findings noted above are separate from code-level review).
- **`sudoku`** — no secrets, no injection risk, dependencies already current on the packages flagged elsewhere.
- **`dotfiles`** — no secrets, no unsafe shell patterns, no hook scripts executing untrusted input.

## Repos Unchanged Since Last Scan (skipped)

`where-it-counts`, `true-cost-of-car-ownership`, `amanda-repository`, `Calculator2.0`, `screenprops`, `amandarae220` (profile), `doteon`, `scamlessgames`, `tamagotchi-game`, `DungeonsAndDragons`, `interactiveResume`, `habitTracker` — identical HEAD commit to the 2026-08-19 checkpoint, no new commits to review.

---

## Top Actions (ranked)

1. **`neo-control`: bump five transitive dependencies** — `react-router-dom@7.18.2+`, `postcss@8.5.23+`, `brace-expansion@1.1.16+`, `nanoid@3.3.16+`, `js-yaml@4.3.1+` (`npm update ... && npm audit fix`). Low real-world exploitability today (none of the five are fed player-controlled input), but each is a routine version bump.
2. **Verify Supabase RLS on `screenprops`'s `projects` table in the live dashboard.** Carried forward — still the only open item requiring action outside the codebase.
3. No other action items this cycle. The one remaining CRITICAL (`amanda-repository`'s burned credential) stays open only as a "confirm not reused elsewhere" reminder, per prior scans.
