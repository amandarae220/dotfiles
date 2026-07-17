# Security Scan — 2026-07-17

## Scope & Methodology

Incremental run. The prior scan (`reports/security-scan-2026-07-04.md`) established a full-fleet baseline across all 15 accessible repos with a per-repo checkpoint commit. This run compares each repo's current HEAD against that checkpoint and deep-scans only repos with new commits since then, per the recurring-scan methodology defined in the baseline report.

**7 of 15 repos had new commits** since 2026-07-04 and were deep-scanned (diff-scoped: prior findings re-verified at current code, plus full review of every commit in the delta range for new issues). The other 8 repos are unchanged since 2026-07-04 and retain their prior status — see "Repos With No Changes" below.

## Checkpoint Table — Updated

| Repo | Prior Checkpoint | Current HEAD | Date | Status |
|---|---|---|---|---|
| neo-control | `144f5d2` (06-23) | `97e4243` | 2026-07-08 | **rescanned** |
| dotfiles | `e763a29` (07-02) | `90b9cb1` | 2026-07-07 | **rescanned** |
| where-it-counts | `218684e` (07-01) | `32084ee` | 2026-07-09 | **rescanned** |
| amanda-repository | `131a77c` (06-18) | `3dddcfd` | 2026-07-09 | **rescanned** |
| Calculator2.0 | `3a4bcf9` (06-18) | `93e0ae5` | 2026-07-07 | **rescanned** |
| screenprops | `19fe372` (06-13) | `fb5662a` | 2026-07-10 | **rescanned** |
| sudoku | `a833819` (2025-02-17) | `b0788f2` | 2026-07-10 | **rescanned** |
| true-cost-of-car-ownership | `21dfc2d` | `21dfc2d` | 2026-06-30 | unchanged |
| amandarae220 (profile) | `2bc6ffb` | `2bc6ffb` | 2026-05-29 | unchanged |
| doteon | `5413b63` | `5413b63` | 2026-05-29 | unchanged |
| scamlessgames | `5303ffc` | `5303ffc` | 2026-05-23 | unchanged |
| tamagotchi-game | `a322c7f` | `a322c7f` | 2026-04-22 | unchanged |
| DungeonsAndDragons | `3ae9643` | `3ae9643` | 2025-12-05 | unchanged |
| interactiveResume | `3e638ca` | `3e638ca` | 2024-07-28 | unchanged |
| habitTracker | `5b4aef4` | `5b4aef4` | 2024-03-09 | unchanged |

---

## ✅ Resolved Since Last Scan

**`neo-control` — all 3 prior findings fixed.**
- **Critical** exposed `VITE_ADMIN_PASS` credential: removed entirely. `AdminPage.tsx` now uses real `supabase.auth.signInWithPassword()` with session restore/sign-out, matching the project's documented architecture. No `VITE_ADMIN_PASS` references remain anywhere in code or `CONTEXT.md`.
- **High** `react-router-dom`/`vite` CVE-flagged versions: bumped via `npm audit fix` to 7.18.1 / 8.1.3.
- **Medium** `js-yaml`/`brace-expansion` moderate DoS advisories: patched to 4.3.0 / 5.0.7.
- New commits in this range (fuel/re-fuel gameplay, death-telemetry logging, new `DeathHeatmap` admin chart) introduced nothing new — reviewed for `innerHTML`, `eval`, insecure transport, RLS-bypassing queries; clean.

**`sudoku` — high-severity toolchain cluster fully resolved.**
- The `react-scripts`/CRA toolchain (57 vulnerabilities: 2 critical, 24 high) was replaced outright — migrated to Vite 7 + `@vitejs/plugin-react` 5, React 19, TypeScript 5.7. `react-scripts` no longer appears anywhere; CRA scaffold files deleted. `npm audit` on the new lockfile: **0 vulnerabilities**.
- New feature commits (win detection, keyboard nav, timer/best-time, tailwind removal) are self-contained client-side game logic — no new network calls, no `innerHTML`/`eval`, no injection surface. `best-time` in `localStorage` is a numeric, non-sensitive value — not an issue for an unauthenticated solitaire game.
- Side finding (housekeeping, not a vuln): a previously-committed `dist`/build output directory was untracked and added to `.gitignore` in this range — good cleanup.

---

## 🔴 Still Open (unresolved across 2+ scan cycles)

- **`Calculator2.0`** — **High.** Stored XSS in `admin.html:551-552` is **unchanged**. `device`/`browser` values (writable by any unauthenticated client via the `calculator_events` table's `insert to anon with check (true)` RLS policy) are still concatenated raw into `innerHTML` for the admin dashboard's filter dropdowns. No code in this repo changed at all since 06-18 other than `CLAUDE.md`/`README.md` — the merged "Feature/angular-makeover" PR was documentation-only despite its name (verified: no Angular tooling, no framework migration, does not contradict the project's single-file-no-build ADR). **This is the second consecutive scan flagging this exact issue with no remediation.** Fix: `textContent`/`createElement` instead of string concatenation, plus a DB-level allow-list on `device`/`browser`.

## 🟡 Still Open (unchanged)

- **`screenprops`** — Ownership scoping on the `projects` table (and ~25 other per-platform tables — tinder, facebook, reddit, imessage, uber, etc.) is still enforced only client-side (`.eq("user_id", user.id)`) with the anon key; no server-side route handlers or in-repo RLS policies. Same unverified-boundary risk as 07-04, now touching more surface area as the app has grown. Verify RLS is airtight in the live Supabase project.
- **`where-it-counts`** — `Scrollytelling.svelte:51`'s `{@html step.text}` is still bound to hardcoded static strings only; the Svelte 5 / Vite 8 migration didn't touch this line or introduce any new `{@html}`/dynamic-markup patterns elsewhere. Still latent, not exploitable today.

## 🆕 New This Cycle

- **Medium — `dotfiles`**: `.claude/skills/global/awesome-skills-reference.md:32-42` (new file) documents a workflow for installing third-party Claude skills via `curl https://officialskills.sh/<org>/<skill-name>` or fetching a `SKILL.md` from an arbitrary GitHub org and writing it directly into `~/.claude/skills/` — no integrity check, no pinned hash, no review step. Since skill files are loaded as trusted instructions in every session (per this session's own system context), this is a documented but **unexecuted** supply-chain / prompt-injection vector: a compromised or typosquatted source could get its instructions silently treated as user-authorized config. Recommend adding a "review contents before installing" caution if this workflow is kept.
- **Low — `where-it-counts`**: `cookie@0.6.0` (transitive via `@sveltejs/kit`/`@sveltejs/adapter-static`) is flagged for GHSA-pxg6-pf52-xh8x (accepts out-of-bounds characters in cookie name/path/domain, fixed in ≥0.7.0). Pre-existing (present before this scan's commit range too, not introduced by the Svelte5/Vite8 bump) but not previously called out — noting now since it surfaced in this pass's `npm audit`.
- **Low — `amanda-repository`**: `CLAUDE.md:12` (added this cycle) states `src/environments/environment.ts` "is gitignored" — it isn't and never has been (only `environment.prod.ts` is ignored; `environment.ts` has been tracked since the file's original commit). No current exposure since the tracked content is the intentionally-public Supabase anon key, but the doc could mislead a future contributor into pasting a real secret there believing it's safe. Fix the doc or actually gitignore the file.

## ⚪ Confirmed No Regression (informational, unchanged)

- **`amanda-repository`**: burned plaintext password + 2 unsalted SHA-256 hashes remain in git history (`commit 875772e`) — still permanently retrievable, current code path unaffected (Supabase Auth only). No new occurrences. The Angular 22 upgrade + Karma→Vitest migration in this range (`ecc101f`, `9eee01b`, `b1fd2fc`) is pure build/tooling churn — reviewed all 12 touched component files and the Express 5 route-syntax change; zero security-relevant code touched, `npm audit --production` clean.
- **`Calculator2.0`**: missing SRI on CDN scripts (D3, Supabase JS) — unchanged, still low.
- **`dotfiles`**: the 06-16 report's previously-quoted plaintext password was retroactively redacted to `[REDACTED]` in an earlier commit — confirmed still redacted. The new skill files and `security-scan-2026-07-04.md` itself were grepped for secrets/keys — none found.
- **`screenprops`**: new "pricing page" (`app/pricing/page.tsx`) is presentational only — no Stripe SDK, no `sk_live`/`sk_test` keys, no checkout route, no server-validated pricing logic exists yet. Flag for the *next* scan once real payment processing is wired in.

---

## Repos With No Changes Since 2026-07-04

Not rescanned — retain prior status from the baseline report (`security-scan-2026-07-04.md`):

- **true-cost-of-car-ownership** — low/informational (missing SRI on Chart.js CDN load)
- **amandarae220 (profile)** — no issues found
- **doteon** — low (`.next/` build output tracked in git)
- **scamlessgames** — high (`next@16.2.3` CVE cluster, unresolved), low (dev-only transitive deps)
- **tamagotchi-game** — high (Angular 21.2.9 XSS-bypass advisories, unresolved)
- **DungeonsAndDragons** — no issues found
- **interactiveResume** — medium (missing SRI on D3/d3-hexbin CDN loads)
- **habitTracker** — no issues found

---

## Top Actions (ranked)

1. **Fix `Calculator2.0`'s stored-XSS in `admin.html:551-552`.** Unresolved for two consecutive scans — this is the highest-severity open item in the fleet right now. `textContent`/`createElement` swap is small and low-risk.
2. **Verify Supabase RLS is airtight for `screenprops`'s ~25+ per-platform tables** — the client-side-only ownership check has no in-repo backstop, and the surface area keeps growing with each new feature page.
3. **Bump `next` in `scamlessgames` and Angular in `tamagotchi-game`** — both still carrying unresolved high-severity dependency CVEs from the baseline scan with no activity since.
4. **Add a review/integrity caveat to `dotfiles`' new `awesome-skills-reference.md`** before its curl-a-skill-from-a-third-party workflow is ever actually used.
5. Nice-to-have: correct the `amanda-repository` CLAUDE.md gitignore claim; add SRI to `Calculator2.0`/`interactiveResume`/`true-cost-of-car-ownership` CDN script tags.
