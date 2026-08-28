# Security Scan — 2026-08-28

## Scope & Methodology

Incremental scan against the checkpoint in `security-scan-2026-08-19.md`. Each of the 15 accessible repos' current HEAD was compared to that checkpoint; only repos with new commits were deep-scanned (full diff review for secrets, injection, auth/RLS regressions, and dependency-manifest changes). Repos with an unchanged HEAD were skipped per protocol — except where a security-relevant finding had already surfaced through the separate monthly code-quality audit (`audit-2026-08-26.md`, `audit-2026-08-27.md`) since the last checkpoint; those are folded in below since they're real open findings on unchanged repos, not new deep-scan output.

## Repos Scanned — Updated Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Status this run |
|---|---|---|---|---|
| neo-control | `8c16c4a9` | 2026-08-26 | amandarae220 | Scanned — diff clean (game-content change only); 5 open dependency CVEs carried in from adjacent audit, see below |
| dotfiles | `a28246c3` | 2026-08-27 | amandarae220 | Scanned — new commits are report additions only (`reports/audit-*.md`), no code touched, clean |
| where-it-counts | `32084ee2` | 2026-07-09 | amandarae220 | No change since last scan — skipped (dependency findings from 08-26 audit noted below) |
| true-cost-of-car-ownership | `21dfc2d3` | 2026-06-30 | amandarae220 | No change since last scan — skipped |
| amanda-repository | `01b0786c` | 2026-08-13 | amandarae220 | No change since last scan — skipped |
| Calculator2.0 | `d68de4a9` | 2026-08-13 | amandarae220 | No change since last scan — skipped |
| screenprops | `fb5662a0` | 2026-07-10 | amandarae220 | No change since last scan — skipped |
| amandarae220 (profile) | `24d9a2cf` | 2026-07-28 | amandarae220 | No change since last scan — skipped (README email exposure from 08-27 audit noted below) |
| doteon | `5413b63a` | 2026-05-29 | amandarae220 | No change since last scan — skipped |
| scamlessgames | `5303ffc2` | 2026-05-23 | psmithskynativ | No change since last scan — skipped |
| DungeonsAndDragons | `3ae9643f` | 2025-12-05 | amandarae220 | No change since last scan — skipped |
| tamagotchi-game | `a322c7f5` | 2026-04-22 | amandarae220 | No change since last scan — skipped (localStorage validation gaps from 08-27 audit noted below) |
| sudoku | `69957efd` | 2026-08-26 | amandarae220 | Scanned — a11y/reduced-motion/theme-toggle diff, clean |
| interactiveResume | `3e638ca3` | 2024-07-28 | amandarae220 | No change since last scan — skipped |
| habitTracker | `5b4aef49` | 2024-03-09 | amandarae220 | No change since last scan — skipped |

**3 of 15 repos had new commits since 2026-08-19 and were deep-scanned (neo-control, dotfiles, sudoku). 12 unchanged and skipped.**

---

## New Issues Found This Run (from today's deep scan)

None. The neo-control diff (wave-2 docking sequence, briefing scrollbar, "MORE" button retirement) and the sudoku diff (aria-live check-result announcement, reduced-motion fix, optional-chaining guard on `matchMedia`) contain no secrets, no injection surface, and no dependency-manifest changes.

## Open Findings Surfaced by the Adjacent Monthly Audits (not from today's diff, still unresolved)

These repos' commits didn't change since 2026-08-19, so they weren't deep-scanned today, but the code-quality audit routine touched them since the last security checkpoint and turned up real security-relevant items that haven't yet appeared in a `security-scan-*.md`. Rolling them in here so this report is a complete picture of what's open.

- **`neo-control` — HIGH, 5 unpatched `npm audit` findings** (found `audit-2026-08-26.md`, confirmed still present — `package.json`/lockfile untouched by today's commits): `react-router-dom` CSRF bypass in RSC mode (GHSA-qwww-vcr4-c8h2, patched in 7.18.2), `js-yaml` quadratic-CPU DoS (CVE-2026-59870), `postcss` path traversal via `sourceMappingURL` (GHSA-fxqj-rqcc-2cmp), `brace-expansion` exponential DoS, `nanoid` infinite loop on negative size. Fix is `npm i react-router-dom@7.18.2 && npm audit fix`.
- **`where-it-counts` — HIGH, 2 unpatched `npm audit` findings**: same `postcss` path-traversal advisory, same `nanoid` infinite-loop advisory, plus `@sveltejs/kit` MODERATE (update to 2.70.3) and `cookie` LOW. Fix is `npm audit fix` + `npm i @sveltejs/kit@latest`.
- **`tamagotchi-game` — MEDIUM, unvalidated localStorage input reaches an asset path.** `src/app/services/pet-state.service.ts:148-172` — `petType` read from `localStorage` is not checked against the known species enum before being interpolated into `getCurrentSpritePath()` (`assets/pets/${petType}/${state}.png`). A tampered localStorage value can path-traverse the asset URL. Fix: validate against `PET_OPTIONS` ids, fall back to a default.
- **`tamagotchi-game` — LOW, unbounded `petName` from localStorage.** Same file, lines 156-158 — no length/character cap before the value is rendered into the DOM. Fix: cap to 32 chars, re-validate with the setup-flow `nameRegex`.
- **`tamagotchi-game` — LOW, `sessionStorage.redirect = ...` property assignment.** `src/404.html:2` bypasses the `Storage` interface (`setItem`). Low-severity correctness/robustness note, not directly exploitable.
- **`amandarae220` (profile) — LOW, personal email hardcoded in public README.** `README.md:30` — will be scraped by bots. Pre-existing, acceptable at low urgency per the 08-27 audit; flagged again here for visibility.

## Still Open — Carried Forward from `security-scan-2026-08-19.md` (unchanged)

- **`amanda-repository` — CRITICAL, burned credential in git history.** The 2026-06-14 plaintext admin password (commit `875772e`) and its two unsalted SHA-256 hashes remain permanently retrievable via `git log --all -p`. Not fixable without a disruptive history rewrite; stays open only as a "confirm not reused elsewhere" reminder. No new commits this window.
- **`screenprops` — MEDIUM, client-side-only ownership enforcement on `projects`.** Both the dashboard read and the delete action scope to `user_id` only via a client-supplied Supabase filter using the anon key; no server-side route handlers or in-repo RLS/schema files to confirm database-level enforcement. **Action still needed: verify RLS is actually enabled on the live Supabase `projects` table** — unverifiable from source. No new commits this window.
- **`where-it-counts` — LOW, latent `{@html}` usage.** `Scrollytelling.svelte:51` still renders `step.text` via `{@html}` with hardcoded literal strings — not exploitable today, would become real XSS if step text is ever sourced from a CMS/API without sanitization. No new commits this window.
- **`Calculator2.0` — LOW/informational, no SRI on CDN scripts.** D3 and Supabase-js still loaded from CDN in `index.html`/`admin.html` without `integrity`/`crossorigin` attributes. No new commits this window.

---

## Repos Confirmed Clean

- **`dotfiles`** — new commits are report files only; no code, no secrets, no shell-script changes.
- **`neo-control`** — today's diff (game content/UI) has no security-relevant surface; dependency CVEs above are pre-existing and tracked separately.
- **`sudoku`** — today's diff (a11y + reduced-motion) has no security-relevant surface.

## Repos Unchanged Since Last Scan (skipped)

`true-cost-of-car-ownership`, `amanda-repository`, `Calculator2.0`, `screenprops`, `amandarae220` (profile), `doteon`, `scamlessgames`, `DungeonsAndDragons`, `tamagotchi-game`, `interactiveResume`, `habitTracker` — identical HEAD to the 2026-08-19 checkpoint.

---

## Top Actions (ranked)

1. **`neo-control`: run `npm i react-router-dom@7.18.2 && npm audit fix`.** Clears a HIGH CSRF bypass plus 4 other HIGH advisories (js-yaml, postcss, brace-expansion, nanoid) in one pass.
2. **`where-it-counts`: run `npm audit fix` and update `@sveltejs/kit` to 2.70.3.** Clears the same postcss/nanoid HIGH advisories plus the sveltekit MODERATE.
3. **`tamagotchi-game`: validate `petType` against `PET_OPTIONS` before building the sprite asset path** (`pet-state.service.ts:148-172`) — closes the localStorage-driven path-traversal vector.
4. **Verify Supabase RLS on `screenprops`'s `projects` table in the live dashboard** — carried from 2026-08-19, still the only open item requiring action outside the codebase.
5. No further action on `amanda-repository`'s burned credential beyond confirming it isn't reused elsewhere — historical exposure, no code-level fix available.
