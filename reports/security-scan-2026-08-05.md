# Security Scan — 2026-08-05

## Scope & Methodology

Incremental scan. Compared against the checkpoint table in [`security-scan-2026-07-04.md`](./security-scan-2026-07-04.md) — the only prior scan of this type. All 15 accessible repos were checked for new commits since their recorded checkpoint SHA; only repos with new commits were deep-scanned. Deep scan covers: exposed secrets/credentials (tracked files + diff history), XSS-class injection risks, dependency vulnerabilities, insecure transport, and exposed/unauthenticated API surface — plus explicit re-verification of every finding open at the 2026-07-04 checkpoint.

**8 of 15 repos had new commits and were deep-scanned.** 7 were unchanged and skipped.

## Repos Scanned — Checkpoint for Next Run

| Repo | Last Commit | Date | Owner | Status |
|---|---|---|---|---|
| neo-control | `97e4243` | 2026-07-08 | amandarae220 | scanned |
| dotfiles | `9e31777` | 2026-07-30 | amandarae220 | scanned |
| where-it-counts | `32084ee` | 2026-07-09 | amandarae220 | scanned |
| amanda-repository | `d8e3777` | 2026-08-04 | amandarae220 | scanned |
| Calculator2.0 | `a36134a` | 2026-07-30 | amandarae220 | scanned |
| screenprops | `fb5662a` | 2026-07-10 | amandarae220 | scanned |
| amandarae220 (profile) | `24d9a2c` | 2026-07-28 | amandarae220 | scanned |
| sudoku | `d295f2b` | 2026-08-03 | amandarae220 | scanned |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | amandarae220 | unchanged — skipped |
| doteon | `5413b63` | 2026-05-29 | amandarae220 | unchanged — skipped |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ | unchanged — skipped |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 | unchanged — skipped |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 | unchanged — skipped |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 | unchanged — skipped |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 | unchanged — skipped |

Findings this run: **0 critical, 0 high, 3 medium, 3 low/informational.** Two prior HIGH findings were confirmed remediated.

---

## ✅ Remediated Since Last Scan

- **`neo-control` — admin auth bypass (was CRITICAL).** The client-side password gate was replaced with real Supabase `signInWithPassword()` auth (commit `ceef7ece9`); `CONTEXT.md`/`CLAUDE.md` references to the literal password were removed and `CLAUDE.md` now explicitly bans reintroducing `VITE_ADMIN_PASS`. Verified in current code, not just claimed.
- **`neo-control` — react-router-dom / vite CVEs (was HIGH).** `npm audit fix` (commit `ccb1e4990`) bumped react-router 7.14.2→7.18.1 and vite 8.0.9→8.1.3.
- **`Calculator2.0` — stored XSS in admin.html (was HIGH).** `populateSelect()` now builds `<option>` elements via `createElement`/`textContent` instead of `innerHTML` string concatenation (commit `e609f4a756a`). A `safeEventTypeClass()` allow-list was also added, closing a secondary CSS-class-injection vector the original finding didn't call out.
- **`sudoku` — CRA/react-scripts toolchain (was HIGH, 57 vulns incl. 2 critical/24 high).** Fully migrated off Create React App to Vite (commit `55fc1ac8`); `react-scripts`, `shell-quote`, and `nth-check` no longer appear in the dependency tree at all. Note: the commit literally titled "npm audit fix" (`d295f2bf`) was cosmetic (only bumped `nanoid`/`postcss`) — the real fix was the earlier framework migration.

---

## 🟡 Medium

- **`neo-control`**: A real (now-decommissioned) admin passphrase remains permanently retrievable via `git log -p` — it sat in tracked `CONTEXT.md` through commit `6819dd2ae` before being scrubbed from the working tree. The auth bypass itself is fixed (mechanism is now Supabase Auth + RLS), so this is a disclosed-credential hygiene issue, not a live vulnerability. **Action: treat the string as burned; rotate anywhere it was reused. True removal requires a history rewrite (BFG/`git filter-repo`) coordinated with any collaborators/forks.**
- **`dotfiles` (this repo) — repeat exposure of the same class of issue.** `reports/security-scan-2026-07-04.md` (commit `1a836e1e`) quoted two real plaintext passwords verbatim in its findings writeup — neo-control's admin passphrase and amanda-repository's already-burned password. A follow-up commit three days later (`b14409e6`) redacted both to `[REDACTED]` in the working tree, but neither value was purged from git history, so this repo now holds an additional permanently-retrievable copy of neo-control's password, independent of neo-control's own repo. This is the same mistake flagged as low-severity in `audit-2026-06-16.md` and repeated in the very report meant to document it. **Action: this report deliberately omits the literal values (see redaction note below); consider a coordinated history purge across both repos if the credential was ever reused; process fix — audit/scan reports should reference findings by file:line, never reproduce secret values.**
- **`screenprops`**: Unchanged from 2026-07-04 — the `projects` table is scoped only via client-side `.eq("user_id", user.id)` queries using the public Supabase anon key. No server-side route handlers, migrations, or RLS policy files exist in-repo to enforce this at the database layer. Cannot be verified further from source; confirm RLS is actually enabled and correct in the live Supabase project.

## 🟢 Low / Informational

- **`Calculator2.0`**: CDN scripts (`d3.v7.min.js`, `@supabase/supabase-js` via jsdelivr) still load without Subresource Integrity attributes. Unchanged since last scan.
- **`where-it-counts`**: `Scrollytelling.svelte:51`'s `{@html step.text}` is still fed only by hardcoded static strings — confirmed unchanged and unescalated through the Svelte 5 / Vite 8 upgrade (PR #8). Remains a latent risk only if that content is ever sourced dynamically.
- **`amanda-repository`**: Calculator2.0's `index.html`/`admin.html` were rehosted wholesale under `public/calculator-v2/` (commit `b5cedfc2`), bringing along a second Supabase project's public anon key (`assets/config.js`). This is the same accepted public-anon-key-plus-RLS pattern already on record for Calculator2.0 — RLS on the new project is verified airtight (anon INSERT-only with `WITH CHECK` field constraints, SELECT scoped to one admin email). Confirmed the already-fixed (non-`innerHTML`) version of `admin.html` was what got copied — no XSS regression. No action needed.

---

## Repos With No Issues Found

- **`amandarae220` (profile)** — two commits since last scan, both cosmetic README edits (added then immediately removed two stats-badge images). No secrets, no workflow changes.
- **`true-cost-of-car-ownership`, `doteon`, `scamlessgames`, `DungeonsAndDragons`, `tamagotchi-game`, `interactiveResume`, `habitTracker`** — no commits since the last scan; not re-scanned. Their most recent findings remain as recorded in `security-scan-2026-07-04.md`.

---

## A Note on This Report's Own Redactions

This scan's subagents retrieved two real (though now-decommissioned/burned) plaintext credential strings while investigating the `neo-control` and `dotfiles` findings above. Per the medium finding on `dotfiles` itself, this report does not reproduce those values — they're referenced only as "the admin passphrase" / "the password," matching file:line instead. Anyone verifying these findings should expect to find the literal values in the relevant commits' diffs, not in this document.

## Top Actions (ranked)

1. **Treat neo-control's decommissioned admin passphrase as burned** — rotate anywhere it may have been reused. The bypass vector is closed; this is residual hygiene.
2. **Decide whether to purge the same credential from dotfiles' own git history** (`reports/security-scan-2026-07-04.md`, commit `1a836e1e`) — it's now a second independent copy. At minimum, adopt a "findings by file:line, never by literal value" rule for all future audit/scan reports in this repo.
3. **Verify screenprops' Supabase RLS policy for `projects`** directly in the Supabase dashboard — the client-side `user_id` filter alone is not a database-enforced boundary.
4. **Add SRI hashes to Calculator2.0's two CDN script tags** (d3, supabase-js) — low effort, closes a long-standing low-severity gap.
