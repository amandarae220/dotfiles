# Security Scan — 2026-07-09

## Scope & Methodology

Incremental run against the checkpoint in [`security-scan-2026-07-04.md`](./security-scan-2026-07-04.md). Only repos with commits newer than their 2026-07-04 checkpoint SHA were deep-scanned; the rest were confirmed unchanged (same latest commit SHA) and skipped per the recurring-scan protocol.

## Repos With Commits Since Last Scan (Deep-Scanned)

| Repo | Checkpoint (07-04) | Latest Now | Date |
|---|---|---|---|
| neo-control | `144f5d2` | `97e4243` | 2026-07-08 |
| where-it-counts | `218684e` | `ae308eb` | 2026-07-08 |
| Calculator2.0 | `3a4bcf9` | `93e0ae5` | 2026-07-07 |
| dotfiles | `e763a29` | `90b9cb1` | 2026-07-07 |
| amanda-repository | `131a77c` | `af59469` | 2026-07-07 |

## Repos Unchanged Since Last Scan (Skipped)

true-cost-of-car-ownership, screenprops, amandarae220 (profile), doteon, scamlessgames, tamagotchi-game, DungeonsAndDragons, sudoku, interactiveResume, habitTracker — all 10 still sit at their 07-04 checkpoint SHA. No action needed.

---

## ✅ Resolved Since Last Scan

**`neo-control` — critical exposed-credential finding is fixed.**
The 07-04 report flagged `VITE_ADMIN_PASS` committed in plaintext in `CONTEXT.md`, inlined into the public bundle, and gating admin access with nothing but a client-side string compare. Since then:
- `ceef7ece` moved `AdminPage.tsx` auth to `supabase.auth.signInWithPassword()` (email + password, session persisted via `supabase.auth.getSession()`), matching the same pattern used in `amanda-repository`.
- `fa0f370c` fully removed every `VITE_ADMIN_PASS` reference from `CONTEXT.md` (env var table and the `/admin` route description).
- `ccb1e49` (`npm audit fix`) + a manual bump landed genuine version upgrades, not just lockfile churn: `react-router-dom`/`react-router` 7.14.2 → 7.18.1 and `vite` 8.0.9 → 8.1.3, both past the versions the 07-04 report cited CVEs against.

No further action needed here — the client-side password gate is gone, not just relocated.

**`dotfiles` — prior redaction request honored.** The 07-04 report's side note ("a second live copy of an already-compromised credential sitting in a different repo... redact it in future writeups") was acted on: both `reports/audit-2026-06-16.md:13` and `reports/security-scan-2026-07-04.md` now read `[REDACTED]` instead of the plaintext password.

## 🔴 High — Still Unresolved (Carried Forward)

**`Calculator2.0` — stored XSS in `admin.html` is still present, unfixed.**
`admin.html:551-552` still concatenates `device`/`browser` values straight from the Supabase `calculator_events` table into `innerHTML`:
```js
deviceSel.innerHTML  = '<option value="">All devices</option>'  + devices.map(function (d)  { return '<option>' + d + '</option>'; }).join('');
browserSel.innerHTML = '<option value="">All browsers</option>' + browsers.map(function (b) { return '<option>' + b + '</option>'; }).join('');
```
The table's RLS insert policy still allows anonymous writes (by design, for the anon-key ingestion pipeline), so this remains an attacker-reachable chain into the admin's authenticated, persisted session. Commits since 07-04 (`cfbe568e` adding `CLAUDE.md`, contact-email/privacy-policy updates) didn't touch this code path. **Fix unchanged from last report:** swap to `textContent`/`createElement`, and add a DB-level allow-list/CHECK constraint on `device`/`browser`.

## No New Issues Found

- **`amanda-repository`** — one new commit, a `CLAUDE.md` documentation file. No secrets, no code changes; confirms in writing that admin auth has no password in source (matches current Supabase-auth state).
- **`dotfiles`** — new commits only add skill reference docs (`web-performance.md`, `web-quality-audit.md`, `seo.md`, `core-web-vitals.md`, `web-best-practices.md`, `awesome-skills-reference.md`) plus the redaction fix above. No secrets in any of them.
- **`where-it-counts`** — 20+ commits since 07-01 (copy/UI polish, test coverage, sidebar work, README updates). No new secrets, no new `{@html}`/`innerHTML` sinks. The previously flagged `Scrollytelling.svelte:51` `{@html step.text}` is unchanged — still only rendering hardcoded static strings, still low/informational (latent risk if that content ever becomes CMS/API-sourced).

---

## Updated Checkpoint Table — All 15 Repos

| Repo | Last Commit | Date | Owner |
|---|---|---|---|
| neo-control | `97e4243` | 2026-07-08 | amandarae220 |
| where-it-counts | `ae308eb` | 2026-07-08 | amandarae220 |
| Calculator2.0 | `93e0ae5` | 2026-07-07 | amandarae220 |
| dotfiles | `90b9cb1` | 2026-07-07 | amandarae220 |
| amanda-repository | `af59469` | 2026-07-07 | amandarae220 |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | amandarae220 |
| screenprops | `19fe372` | 2026-06-13 | amandarae220 |
| amandarae220 (profile) | `2bc6ffb` | 2026-05-29 | amandarae220 |
| doteon | `5413b63` | 2026-05-29 | amandarae220 |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 |
| sudoku | `a833819` | 2025-02-17 | amandarae220 |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 |

## Top Actions (ranked)

1. Fix the still-open stored-XSS in `Calculator2.0/admin.html:551-552` — the one carryover item from 07-04 that hasn't moved.
2. No action needed on `neo-control` — both the critical credential exposure and its dependency CVEs are resolved.
