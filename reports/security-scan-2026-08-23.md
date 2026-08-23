# Security Scan — 2026-08-23

## Scope & Methodology

Incremental scan against the checkpoint in `security-scan-2026-08-19.md`. Each of the 15 accessible repos' current HEAD commit was compared to that checkpoint. No repo has a new commit since the last scan.

## Repos Checked — Checkpoint Unchanged

| Repo | Last Commit | Date | Owner | Status this run |
|---|---|---|---|---|
| neo-control | `683fac28` | 2026-08-13 | amandarae220 | No change — skipped |
| dotfiles | `7bf7248` | 2026-08-19 | amandarae220 | No change since last scan's own report commit — skipped |
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
| sudoku | `923a3c1` | 2026-08-10 | amandarae220 | No change — skipped |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 | No change — skipped |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 | No change — skipped |

**0 of 15 repos updated since 2026-08-19. No detailed scanning performed this run** (per scan protocol: skip deep scan when a repo's HEAD is unchanged since the last checkpoint).

---

## Carried-Forward Open Items (unchanged, not re-verified this run)

These remain open per the 2026-08-19 report. Since no repo changed, none were re-scanned or re-verified this run:

- **`amanda-repository` — CRITICAL, burned credential in git history** (2026-06-14 plaintext admin password, commit `875772e`). No code fix possible; treat as burned, confirm not reused elsewhere.
- **`screenprops` — MEDIUM, client-side-only ownership enforcement on `projects`.** Still needs live Supabase RLS verification — not confirmable from source.
- **`where-it-counts` — LOW, latent `{@html}` usage** in `Scrollytelling.svelte:51` (hardcoded literal strings today, not exploitable).
- **`Calculator2.0` — LOW/informational, no SRI on CDN scripts** (D3, Supabase-js in `index.html`/`admin.html`).

## New Issues Found This Run

None — no repos were updated, so no new code was scanned.

---

## Top Actions (ranked)

1. **Verify Supabase RLS on `screenprops`'s `projects` table in the live dashboard** — still the only action item requiring work outside the codebase.
2. No other action items. Next scan will re-check all 15 repos' HEADs against this checkpoint table.
