# Security Scan — 2026-07-08

## Scope & Methodology

Incremental scan against the [2026-07-04 baseline](./security-scan-2026-07-04.md). Per the checkpoint table in that report, each of the 15 accessible repos was compared (latest commit SHA vs. baseline SHA) to identify what changed. Only repos with new commits since the baseline were deep-scanned; the rest were skipped as unchanged.

**4 of 15 repos had new commits** since 2026-07-04: `neo-control`, `dotfiles`, `amanda-repository`, `Calculator2.0`. The other 11 — including `where-it-counts`, which has commits that *look* recent but all predate the 2026-07-04 baseline commit — are unchanged and were not re-scanned.

## Repos Scanned — Updated Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Status |
|---|---|---|---|---|
| neo-control | `61968c9` | 2026-07-08 | amandarae220 | Rescanned |
| dotfiles | `90b9cb1` | 2026-07-07 | amandarae220 | Rescanned |
| amanda-repository | `af59469` | 2026-07-07 | amandarae220 | Rescanned |
| Calculator2.0 | `93e0ae5` | 2026-07-07 | amandarae220 | Rescanned |
| where-it-counts | `218684e` | 2026-07-01 | amandarae220 | No change — skipped |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | amandarae220 | No change — skipped |
| screenprops | `19fe372` | 2026-06-13 | amandarae220 | No change — skipped |
| amandarae220 (profile) | `2bc6ffb` | 2026-05-29 | amandarae220 | No change — skipped |
| doteon | `5413b63` | 2026-05-29 | amandarae220 | No change — skipped |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ | No change — skipped |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 | No change — skipped |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 | No change — skipped |
| sudoku | `a833819` | 2025-02-17 | amandarae220 | No change — skipped |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 | No change — skipped |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 | No change — skipped |

---

## Prior Findings — Resolution Status

### `neo-control`

**🚨 Critical — exposed `VITE_ADMIN_PASS` — PARTIALLY RESOLVED**
- `6819dd2` ("security fixes") and `fa0f370` ("removing refs to admin password since it is no longer used") removed the plaintext value and all references from the current tree. `CONTEXT.md` is clean; a full-tree grep for the old password string returns no hits outside a benign "don't reintroduce this" note in `CLAUDE.md`.
- The auth flow itself was properly rebuilt: `ceef7ec` ("manual auth updates") replaced the client-side string-compare in `AdminPage.tsx` with real `supabase.auth.signInWithPassword()`, session restore via `getSession()`, and sign-out — matching the RLS-is-the-real-boundary design already documented in this repo's CLAUDE.md. No client-side-only bypass was reintroduced.
- **Still open:** the old plaintext password (`checkadmininsights`) remains permanently retrievable via `git log --all -p -- CONTEXT.md` (present in 2 historical commits). Removing it from HEAD doesn't purge history. **Action: confirm this password was rotated/disabled in Supabase (it should already be functionally dead now that admin auth requires a real Supabase login, but treat it as burned regardless); rewrite history via `git filter-repo`/BFG only if this repo becomes public or the value was reused elsewhere.**

**🔴 High — `react-router-dom`/`vite` CVEs — RESOLVED**
`ccb1e49` ("npm audit fix") bumped `react-router`/`react-router-dom` 7.14.2 → 7.18.1 and `vite` 8.0.9 → 8.1.3 in the lockfile. `npm audit` on the current tree reports 0 vulnerabilities.

**🟡 Medium — `js-yaml`/`brace-expansion` — RESOLVED**
Same commit bumped `js-yaml` 4.1.1 → 4.3.0 and `brace-expansion` 5.0.5 → 5.0.7.

No new secrets, no new `dangerouslySetInnerHTML`/`eval`/`new Function`, no new attack surface introduced by the feature commits in this window (storyline/ship/readme updates, new `CLAUDE.md`).

### `Calculator2.0`

**🔴 High — stored XSS in `admin.html` — NOT RESOLVED (untouched)**
The two new commits (`6722a74`, `cfbe568`) only touched `README.md` and added `CLAUDE.md` — confirmed via `git diff --stat` against baseline. `admin.html:551-552` is byte-for-byte unchanged: `device`/`browser` values from the anon-writable `calculator_events` Supabase table are still concatenated into `innerHTML` for `<option>` tags. **This is still a live, unaddressed attacker-reachable stored-XSS chain — carrying over as this run's top action item.**

### `amanda-repository`

Clean. The single new commit (`af59469`) adds a `CLAUDE.md` file only — pure documentation, no secrets, no reference to the old burned password from history.

### `dotfiles`

Clean, with one low-severity advisory. New commits added six global skill files and wired them into `.claude/CLAUDE.md`; also redacted a previously plaintext-leaked password in two old report files (a genuine fix, not a new exposure). One new skill file, `awesome-skills-reference.md` (lines ~405-416), documents a workflow for pulling third-party skill files directly into the loaded-skills path via `curl`/`gh api` with no verification step specified — not malicious, but a supply-chain vector worth a manual-review requirement before anyone follows it.

---

## Summary

| Severity | Count | Status |
|---|---|---|
| 🚨 Critical | 1 (carried over) | Partially resolved — dead credential, purge history if repo goes public |
| 🔴 High | 2 (carried over) | 1 resolved (neo-control deps), 1 still open (Calculator2.0 XSS) |
| 🟡 Medium | 1 (carried over) | Resolved (neo-control deps) |
| 🟢 Low/Informational | 1 (new) | dotfiles skill-import workflow — advisory only |

## Top Actions (ranked)

1. **Fix the stored-XSS path in `Calculator2.0`'s `admin.html:551-552`** — unresolved since 2026-07-04, still a real attacker-reachable chain via the anon-writable `calculator_events` table. Use `textContent`/`createElement` instead of string-concatenated `innerHTML`, and add a DB-level allow-list/CHECK constraint on `device`/`browser`.
2. **Confirm the old `neo-control` admin password was rotated in Supabase.** It's functionally dead (auth now requires real Supabase login) but permanently recoverable from git history — treat as burned.
3. (Advisory) Add a review requirement before importing skill files via the workflow documented in `dotfiles/.claude/skills/global/awesome-skills-reference.md`.

All other repos: no action needed this run.
