# Security Scan — 2026-09-18

## Scope & Methodology

Incremental scan against the checkpoint established in `security-scan-2026-09-16.md`. Each of the 15 accessible repos' current HEAD commit was compared to that report's checkpoint table.

## Result: No repos updated since last scan

All 15 repos' HEAD commits are **identical** to the 2026-09-16 checkpoint, with one technical exception: `dotfiles` itself gained a new commit — but that commit is the previous scan's own report file (`security-scan-2026-09-16.md`, `e057d3f2`), not application code or config. No repo in scope has had a genuine code, dependency, or infrastructure change in this window.

Per the skip protocol, **detailed scanning was not performed this run** — there is nothing new to scan.

## Repos Checked — Checkpoint (unchanged from 2026-09-16)

| Repo | Last Commit | Date | Owner | Status this run |
|---|---|---|---|---|
| neo-control | `8c16c4a9` | 2026-08-26 | amandarae220 | No change — skipped |
| dotfiles | `e057d3f2` | 2026-09-16 | amandarae220 | Only change is the prior scan's own report commit — no code, skipped |
| sudoku | `69957efd` | 2026-08-26 | amandarae220 | No change — skipped |
| where-it-counts | `32084ee` | 2026-07-09 | amandarae220 | No change — skipped |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | amandarae220 | No change — skipped |
| amanda-repository | `01b0786` | 2026-08-13 | amandarae220 | No change — skipped |
| Calculator2.0 | `d68de4a` | 2026-08-13 | amandarae220 | No change — skipped |
| screenprops | `fb5662a` | 2026-07-10 | amandarae220 | No change — skipped |
| amandarae220 (profile) | `24d9a2c` | 2026-07-28 | amandarae220 | No change — skipped |
| doteon | `5413b63` | 2026-05-29 | amandarae220 | No change — skipped |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ | No change — skipped |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 | No change — skipped |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 | No change — skipped |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 | No change — skipped |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 | No change — skipped |

**0 of 15 repos updated with new code since 2026-09-16. 15 unchanged (14 truly untouched, 1 — dotfiles — touched only by the prior report commit).**

---

## Findings by Severity

No new findings this run (nothing was deep-scanned). Carrying forward open items from `security-scan-2026-09-16.md` for visibility, none re-verified:

### 🔴 High (open, unpatched)

- **`neo-control` — 5 HIGH `npm audit` advisories, including a CSRF bypass**, first flagged 2026-09-16 and still unaddressed as of this run (HEAD unchanged: `8c16c4a9`). `react-router`/`react-router-dom` (GHSA-qwww-vcr4-c8h2, affects `>=7.12.0 <7.18.2`), plus `js-yaml`, `postcss`, `brace-expansion`, `nanoid` advisories. **Fix still pending:** `npm i react-router-dom@7.18.2 && npm audit fix`.

### Carried forward (unchanged, not re-verified)

- **`amanda-repository` — CRITICAL (historical), burned credential in git history.** 2026-06-14 plaintext admin password + two unsalted SHA-256 hashes remain retrievable via `git log --all -p`. No history rewrite performed. Open only as a "confirm not reused elsewhere" reminder.
- **`screenprops` — MEDIUM, client-side-only ownership enforcement on `projects`.** Still unverified whether Supabase RLS is enabled on the live table.
- **`where-it-counts` — LOW, latent `{@html}` usage** in `Scrollytelling.svelte:51`.
- **`Calculator2.0` — LOW/informational, no SRI on CDN scripts.**

## Repos Confirmed Clean

None re-verified this run (no diffs to review).

---

## Top Actions (ranked)

1. **Patch `neo-control` dependencies** — still open since 2026-09-16, now going on its second scan cycle unpatched: `npm i react-router-dom@7.18.2 && npm audit fix`.
2. **Verify Supabase RLS on `screenprops`'s `projects` table** in the live dashboard (carried forward, still needs a check outside the codebase).
3. No new action items this run — no repo activity to scan.
