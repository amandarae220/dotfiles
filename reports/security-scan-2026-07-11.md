# Security Scan — 2026-07-11

## Scope & Methodology

Diff-based run against the checkpoint in `reports/security-scan-2026-07-04.md`. 7 of 15 accessible repos had new commits since that checkpoint and were deep-scanned (diff review of every commit since the last-scanned SHA, plus a fresh check of previously-flagged findings). The other 8 repos had no new commits and were skipped per the checkpoint protocol.

Each scanned repo was checked for: exposed secrets/credentials, XSS-class injection, dependency vulnerabilities, insecure transport, and exposed/unauthenticated API surface — with specific attention to whether prior findings were fixed, still present, or worsened.

## Repos Scanned This Run (had new commits)

| Repo | Prior Commit | New Commit | Date |
|---|---|---|---|
| neo-control | `144f5d2` (06-23) | `97e4243` | 2026-07-08 |
| dotfiles | `e763a29` (07-02) | `90b9cb1` | 2026-07-07 |
| where-it-counts | `218684e` (07-01) | `32084ee` | 2026-07-09 |
| amanda-repository | `131a77c` (06-18) | `3dddcfd` | 2026-07-09 |
| Calculator2.0 | `3a4bcf9` (06-18) | `93e0ae5` | 2026-07-07 |
| screenprops | `19fe372` (06-13) | `fb5662a` | 2026-07-10 |
| sudoku | `a833819` (2025-02-17) | `b0788f2` | 2026-07-10 |

## Repos Skipped — No New Commits Since Last Checkpoint

| Repo | Commit | Date |
|---|---|---|
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 |
| amandarae220 (profile) | `2bc6ffb` | 2026-05-29 |
| doteon | `5413b63` | 2026-05-29 |
| scamlessgames | `5303ffc` | 2026-05-23 |
| tamagotchi-game | `a322c7f` | 2026-04-22 |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 |
| interactiveResume | `3e638ca` | 2024-07-28 |
| habitTracker | `5b4aef4` | 2024-03-09 |

**Findings this run: 0 new critical, 1 open high (carried over, unfixed), 1 new medium, 2 informational notes.** Two previously-open items (1 critical, 1 high) were confirmed fixed.

---

## ✅ Fixed Since Last Scan

**`neo-control` — critical plaintext admin passphrase: FIXED.**
`ceef7ece94` replaced the client-side `VITE_ADMIN_PASS` string-compare in `AdminPage.tsx` with real Supabase Auth (`signInWithPassword` + session restore + `signOut`). `fa0f370c` stripped all `VITE_ADMIN_PASS` references from `CONTEXT.md`. Repo-wide search confirms zero remaining hits — auth now matches the project's own documented rule that RLS is the real guard. (The old value `checkadmininsights` still lives in git history predating this window; treat as burned if reused elsewhere, no action needed in-repo.)

**`neo-control` — high-severity dependency CVEs: FIXED.**
`ccb1e499` ("npm audit fix") bumped `react-router-dom` 7.14.2→7.18.1 and `vite` 8.0.9→8.1.3 in the lockfile, resolving the DoS/CSRF/NTLMv2 CVEs flagged last scan. `js-yaml`/`brace-expansion` moderate advisories also resolved (4.3.0 / 1.1.14).

**`sudoku` — 57 npm audit vulnerabilities (2 critical, 24 high) in CRA toolchain: FIXED.**
Full migration off Create React App / `react-scripts` to Vite (`vite@7.3.6`) + Vitest, landed across several commits over the past year. `react-scripts`, `shell-quote`, and `nth-check` are gone from the lockfile entirely; `form-data` and `ws` are on patched versions. The new "timer + best time" feature (`b0788f2`) only persists a single integer to `localStorage`, rendered via normal JSX text interpolation — no new injection surface. App remains fully static/client-only.

**`dotfiles` — burned credential quoted verbatim in an old report: FIXED.**
Commit `b14409e` redacted the plaintext password that had been quoted in `reports/audit-2026-06-16.md` and last week's `security-scan-2026-07-04.md`; both now read `[REDACTED]`.

---

## 🔴 High — Still Open (unfixed for 1+ week)

**`Calculator2.0` — stored XSS in `admin.html:551-552`.**
Unchanged since 2026-07-04. `populateDeviceAndBrowserFilters()` still concatenates `device`/`browser` values — sourced from the `calculator_events` Supabase table, which anyone can write to via the public anon key (`RLS: anon insert with check (true)`) — directly into `innerHTML` for `<option>` tags. Attacker-reachable: an unauthenticated client can insert a malicious `device`/`browser` string that executes in the admin's browser, which persists its session (`persistSession: true`). The rest of `admin.html` already uses safe `createElement`/`textContent` elsewhere — this function is the one holdout.
Note: the PR that landed this window (`93e0ae5`, branch name `feature/angular-makeover`) only added `CLAUDE.md` and touched `README.md` — **no Angular migration actually occurred** despite the branch/PR name; `admin.html` is untouched.
**Fix:** swap the two `innerHTML` concatenations for `createElement`/`textContent` (matching the rest of the file), and consider a DB-level CHECK constraint/allow-list on `device`/`browser`.

---

## 🟡 Medium

**`neo-control` — new death path bypasses `killPlayer()` and the shield check.**
Commit `efcee391` (fuel-depletion game-over) inlines death logic in `tickDebris()` instead of calling `killPlayer()`, which this project's own `CONTEXT.md` requires for every death trigger specifically so the shield-powerup check stays centralized. Concretely: a player holding the shield powerup still dies instantly when fuel hits zero (shield does nothing here, unlike every other death cause), and it force-sets `lives = 0` instead of decrementing like the normal flow. Not a traditional security vuln, but a real regression against the project's documented invariant and a gameplay-correctness bug. **Fix:** route the fuel-out death through `killPlayer(gs)`.

**`screenprops` — client-side-only ownership scoping on `projects` table: unverifiable from code, unchanged status.**
Same finding as 2026-07-04. No RLS policy/migration file exists in-repo; the two commits since last scan (a pricing page, an animation/reduced-motion fix) don't touch this path. **This can only be confirmed by checking the Supabase dashboard directly** — verify RLS is actually enabled and correct on `projects`.

---

## 🟢 Informational

- **`amanda-repository`**: `vitest` pinned `^4.0.8` in `package.json` looked concerning (two 2026 CVEs affect `<4.1.6`), but the lockfile resolves to `4.1.10` — already past both fixes. No action needed, noted for awareness.
- **`amanda-repository`**: `CLAUDE.md` states `environment.ts` is gitignored, but `.gitignore` only excludes `environment.prod.ts` — `environment.ts` (containing the intentionally-public Supabase URL/anon key) is actually tracked. Not a new exposure since the anon key is meant to be public and RLS is the real boundary, but the doc/gitignore mismatch could bite if a real secret is ever added to that file believing it's excluded. Worth fixing the `.gitignore` pattern or the doc claim.
- **`screenprops`**: `next` is pinned at `16.2.6`, past this scan's training-data cutoff for reliably recalling CVEs. Repo's own AGENTS.md already warns this Next.js version has unfamiliar breaking changes (confirmed: `middleware.ts` → `proxy.ts` rename). Recommend checking GitHub Security Advisories / the Next.js changelog directly for this version rather than relying on scan memory.
- **`where-it-counts`**: Svelte 5.56.4 / Vite 8.1.4 (Vite 8 now bundles via rolldown instead of esbuild/rollup) upgrade landed cleanly — no new secrets, no `innerHTML`/`eval`, no non-HTTPS calls. The two non-tooling code changes were Svelte-5-compiler-mandated a11y fixes (improvements). Rolldown is young and has a shorter security track record than esbuild — no known CVEs, just worth watching as it matures.

## Repos Confirmed Clean This Run

- **`dotfiles`** — new content this window was 5 new skill-library markdown docs + a redaction fix (see Fixed section); no secrets, no risky scripts.
- **`sudoku`** — see Fixed section; no open findings.

---

## Top Actions (ranked)

1. **Fix the stored-XSS in `Calculator2.0/admin.html:551-552`** — this has now been open for a full week with a live, unauthenticated-writable attack path into the admin's persistent session. Same fix as last week: `createElement`/`textContent` instead of string-concatenated `innerHTML`.
2. **Verify RLS on `screenprops`'s `projects` table in the Supabase dashboard** — still unconfirmed from code alone after multiple scan cycles.
3. **Route `neo-control`'s fuel-depletion death through `killPlayer()`** — closes the shield-bypass regression.
4. Nice work on `neo-control` (admin auth + dependency CVEs) and `sudoku` (full CRA→Vite toolchain migration) — both fully resolved prior findings this cycle.
