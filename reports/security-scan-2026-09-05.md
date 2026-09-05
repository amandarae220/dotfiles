# Security Scan — 2026-09-05

## Scope & Methodology

Incremental scan against the checkpoint in `security-scan-2026-08-19.md`. Each of the 15 accessible repos' current HEAD was compared to that report's checkpoint table; only repos with new commits since the checkpoint were deep-scanned (full diff review for secrets, auth/RLS-relevant changes, and dependency manifest changes). Repos with an unchanged HEAD were skipped per protocol, but any security-relevant findings surfaced by the interim monthly-audit runs (2026-08-26, 2026-08-27) are carried forward below since they remain unresolved.

## Repos Scanned — Updated Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Status this run |
|---|---|---|---|---|
| neo-control | `8c16c4a9` | 2026-08-26 | amandarae220 | Scanned — clean, no new findings |
| dotfiles | `a28246c` | 2026-08-27 | amandarae220 | Scanned — clean (report files only) |
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
| sudoku | `69957ef` | 2026-08-26 | amandarae220 | Scanned — clean, no new findings |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 | No change since last scan — skipped |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 | No change since last scan — skipped |

**3 of 15 repos updated since 2026-08-19 and deep-scanned. 12 unchanged and skipped.**

---

## New Issues Found This Run

None. Both updated repos' diffs were reviewed line-by-line:

- **`neo-control`** (`683fac28` → `8c16c4a9`, 3 commits): all changes confined to `src/game/GameCanvas.tsx` — a wave-2 "dock with the Xylon freighter" narrative/visual addition plus a draggable briefing scrollbar (mouse wheel + pointer-drag). No auth, RLS, Supabase, or admin-dashboard code touched. `killPlayer()`/`imageSmoothingEnabled` reset/`gsRef.current` conventions from `CLAUDE.md` remain intact. No secrets, no unsafe DOM sinks.
- **`sudoku`** (`923a3c1` → `69957ef`, 4 commits): accessibility-focused — app-wide `prefers-reduced-motion` support, a live-region announcement for the self-check conflict count, and an optional-chaining defensive fix (`window.matchMedia?.(...)?.matches`) guarding against a crash when `matchMedia` is undefined. Two new test files, no production dependency or auth-surface changes.
- **`dotfiles`** (`9e31777` → `a28246c`): only new report markdown files added (`audit-2026-08-26.md`, `audit-2026-08-27.md`, `security-scan-2026-08-19.md`). No code, no secrets, no credential-shaped strings.

Neither updated repo touched a `package.json`/lockfile, so no new dependency-vulnerability surface was introduced this run.

---

## Still Open (carried forward, unchanged)

### Critical

- **`amanda-repository`** — burned credential in git history. The 2026-06-14 plaintext admin password (commit `875772e`) and its two unsalted SHA-256 hashes remain permanently retrievable via `git log --all -p`. History has not been rewritten (expected — rewriting shared history is a deliberate, disruptive action). Not fixable by further code changes; treat as burned and rotate anywhere it may have been reused.

### High

- **`neo-control`** — `npm audit` reported 6 HIGH vulnerabilities as of the 2026-08-26 monthly audit, still unaddressed (no `package.json`/lockfile commit since): `react-router`/`react-router-dom` CSRF bypass in RSC mode (GHSA-qwww-vcr4-c8h2, fix: `npm i react-router-dom@7.18.2`), `js-yaml` quadratic-CPU DoS (GHSA-5p4m-2wfm-xmqj), `postcss` path traversal via sourceMappingURL (GHSA-fxqj-rqcc-2cmp), `brace-expansion` exponential-expansion DoS (GHSA-3jxr-9vmj-r5cp), `nanoid` infinite loop on negative size (GHSA-28wg-ghj8-5hjv). `npm audit fix` plus the explicit `react-router-dom` bump should clear all five.
- **`where-it-counts`** — `npm audit` reported HIGH `postcss` (same sourceMappingURL advisory) and HIGH `nanoid` (same infinite-loop advisory) as of the 2026-08-26 monthly audit. Repo HEAD unchanged since 2026-07-09, so still open. `npm audit fix` should resolve both.

### Medium

- **`screenprops`** — client-side-only ownership enforcement on `projects`. Both the dashboard read (`app/dashboard/page.tsx:34-38`) and the delete action (`DashboardClient.tsx:41`) scope to `user_id` only via a client-supplied Supabase filter using the anon key. No server-side route handlers or RLS/schema SQL exist in-repo to confirm enforcement lives in the database. Unchanged since 2026-07-10. **Action still needed: confirm RLS is actually enabled and correctly scoped on the live Supabase `projects` table** — this can't be verified from source code alone.
- **`where-it-counts`** — `@sveltejs/kit` MODERATE advisory flagged in the 2026-08-26 audit (`npm i @sveltejs/kit@latest` → 2.70.3). Repo unchanged since, still open.
- **`tamagotchi-game`** — unsanitized `localStorage` deserialization. `petType`/`baseState` read from `localStorage` are assigned without validation against known enum values (`src/app/services/pet-state.service.ts:148-172`), and `petType` feeds directly into an asset-path template (`assets/pets/${petType}/${state}.png`, line 131). A tampered `petType` value (e.g. `../../evil`) could cause path traversal in the constructed URL. Flagged in the 2026-08-27 monthly audit; repo HEAD unchanged since 2026-04-22, so still open. Fix: validate against the `PET_OPTIONS` id list before assigning, falling back to a default on invalid values.

### Low

- **`where-it-counts`** — latent `{@html}` usage. `Scrollytelling.svelte:51` still renders `step.text` via `{@html}`. Values remain hardcoded literal strings — not exploitable today, but would become real XSS if step text is ever sourced from a CMS/API without sanitization.
- **`Calculator2.0`** — no SRI on CDN scripts. D3 and Supabase-js are still loaded from CDN in `index.html`/`admin.html` without `integrity`/`crossorigin` attributes.
- **`where-it-counts`** — `cookie` package LOW advisory from the 2026-08-26 audit, unresolved (`npm audit fix`).
- **`tamagotchi-game`** — `petName` accepted from `localStorage` without length/character validation (`pet-state.service.ts:156-158`); a tampered value could inject an oversized string into the DOM. Fix: cap to 32 chars and re-validate against the existing `nameRegex`.
- **`tamagotchi-game`** — `src/404.html:2` uses property assignment (`sessionStorage.redirect = ...`) instead of `sessionStorage.setItem(...)`, bypassing the `Storage` interface. Low-risk stylistic/robustness issue, not directly exploitable.
- **`amandarae220` (profile)** — personal email hardcoded in public README (`README.md:30`). Informational; acceptable for a contact page, low urgency.

---

## Repos Confirmed Clean

- **`neo-control`** — this run's diff reviewed in full; no secrets, no auth/RLS surface touched, established game-loop and canvas conventions preserved.
- **`sudoku`** — this run's diff reviewed in full; accessibility/test-only changes, no new attack surface.
- **`dotfiles`** — new files this run are report markdown only; no secrets, no unsafe shell patterns.

## Repos Unchanged Since Last Scan (skipped)

`where-it-counts`, `true-cost-of-car-ownership`, `amanda-repository`, `Calculator2.0`, `screenprops`, `amandarae220` (profile), `doteon`, `scamlessgames`, `tamagotchi-game`, `DungeonsAndDragons`, `interactiveResume`, `habitTracker` — identical HEAD commit to the 2026-08-19 checkpoint (or, for `where-it-counts`/`tamagotchi-game`/`amandarae220`, unchanged since their respective interim monthly audits), no new commits to review.

---

## Top Actions (ranked)

1. **[`neo-control`] Run `npm i react-router-dom@7.18.2 && npm audit fix`.** Clears an actively-patched CSRF bypass (GHSA-qwww-vcr4-c8h2) plus 4 other HIGH advisories in one pass. Highest-severity open item with a trivial fix.
2. **[`where-it-counts`] Run `npm audit fix` and bump `@sveltejs/kit` to 2.70.3.** Clears 2 HIGH + 1 MODERATE + 1 LOW advisory.
3. **[`screenprops`] Verify Supabase RLS on the `projects` table in the live dashboard.** Still the only open item that requires action outside the codebase — unchanged since 2026-07-10.
4. **[`tamagotchi-game`] Validate `petType`/`baseState` against known enums before use in the asset-path template.** Closes the path-traversal-shaped gap in `pet-state.service.ts:148-172`.
5. No action available on `amanda-repository`'s burned credential beyond the standing "confirm not reused elsewhere" reminder — historical exposure, not fixable via further commits.
