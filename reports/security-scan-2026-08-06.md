# Security Scan — 2026-08-06

## Scope & Methodology

Incremental scan against the checkpoint established in `reports/security-scan-2026-07-04.md`. Only repos with commits since that checkpoint's recorded last-commit SHA were deep-scanned; unchanged repos were skipped per the recurring-scan protocol. Each updated repo was reviewed (read-only, no files modified) for: exposed secrets/credentials (tracked files + recent history), XSS-class injection risks, dependency vulnerabilities, insecure/broken authorization, and regressions on prior findings.

## Repos Scanned — Checkpoint for Next Run

8 of 15 accessible repos had new commits since the 2026-07-04 checkpoint and were scanned:

| Repo | Last Commit | Date | Owner |
|---|---|---|---|
| Calculator2.0 | `a36134a` | 2026-07-30 | amandarae220 |
| amanda-repository | `d8e3777` | 2026-08-04 | amandarae220 |
| dotfiles | `9e31777` | 2026-07-30 | amandarae220 |
| neo-control | `97e4243` | 2026-07-08 | amandarae220 |
| screenprops | `fb5662a` | 2026-07-10 | amandarae220 |
| sudoku | `d295f2b` | 2026-08-03 | amandarae220 |
| where-it-counts | `32084ee` | 2026-07-09 | amandarae220 |
| amandarae220 (profile) | `24d9a2c` | 2026-07-28 | amandarae220 |

7 of 15 repos had no commits since the checkpoint and were **not** re-scanned this run (unchanged SHA): `true-cost-of-car-ownership` (`21dfc2d`), `doteon` (`5413b63`), `scamlessgames` (`5303ffc`), `tamagotchi-game` (`a322c7f`), `DungeonsAndDragons` (`3ae9643`), `interactiveResume` (`3e638ca`), `habitTracker` (`5b4aef4`).

Findings this run: **0 critical, 0 high (2 prior highs confirmed fixed), 1 medium (carried forward, unresolved), 8 low/informational.**

---

## 🔴 High — Prior Findings, Status Update

Both HIGH-severity issues from the 2026-07-04 baseline are **confirmed fixed**, with no regression and no new HIGH/CRITICAL findings introduced:

- **`Calculator2.0` stored XSS — FIXED.** The `admin.html` device/browser `<option>` list (previously built via string-concatenated `innerHTML` fed by an anon-writable Supabase table) now uses `document.createElement` + `.textContent` (commit `e609f4a7`, 2026-07-30). The same commit also whitelists `event_type` against a known-values list before using it in a CSS class name, closing a related class-injection vector. No residual risk found.
- **`sudoku` toolchain vulnerabilities — FIXED.** The "v2-redesign" (PR #2) was a genuine migration off Create React App to Vite 7.3.6 — `react-scripts` and its 57-vulnerability dependency tree (shell-quote, form-data, nth-check, ws) are completely gone, not patched-in-place. Verified via direct `package-lock.json` inspection: zero occurrences of `react-scripts`.

## 🟡 Medium

- **`screenprops` — `projects` table authorization is still purely client-side (unchanged from baseline).** Every read/write/delete against `projects` (and the same pattern repeated across platform-builder pages — dashboard, imessage, etc.) filters with `.eq("user_id", user.id)` using the public anon key, with no in-repo RLS policy files or API route handlers enforcing it server-side. Moving the dashboard's read query into a React Server Component (since baseline) does not close this gap — a user's own JWT can call the Supabase REST API directly and bypass the app entirely. **If RLS on `projects` isn't enabled/correct in the live Supabase project, any authenticated user can read/modify/delete other users' rows.** Action: verify RLS in the Supabase dashboard; this has now been flagged in two consecutive scans.

## 🟢 Low / Informational

- **`neo-control`**: The old `VITE_ADMIN_PASS` value (`[REDACTED]`) is gone from `CONTEXT.md` (commit `fa0f370`) and the auth gate is now genuinely server-side (`supabase.auth.signInWithPassword`, no client-side string compare) — but the plaintext passphrase remains permanently visible in git history (commit `6819dd2`). Rotate it anywhere it may have been reused; functionally non-exploitable now since the gate itself no longer exists.
- **`neo-control`**: `CONTEXT.md`'s mandated commit log is stale — it doesn't document the four most security-relevant commits (the auth migration, password-reference removal, "security fixes," and `npm audit fix`). Process gap, not a vulnerability.
- **`dotfiles`**: The plaintext password previously quoted in `reports/audit-2026-06-16.md:13` and `reports/security-scan-2026-07-04.md` (a copy of the already-burned `amanda-repository` credential) has been redacted (commit `b14409e`, 2026-07-07) — **resolved**. `git/gitconfig`'s HTTPS→SSH URL rewrite remains, unchanged — informational only, not a vulnerability.
- **`where-it-counts`**: `Scrollytelling.svelte:51`'s `{@html step.text}` is still fed exclusively by hardcoded static strings (`+page.svelte`) post the Svelte5/Vite8 upgrade — latent XSS risk only if that content is ever sourced externally without sanitization. No CDN-script-without-SRI issue here (only Google Fonts CSS is loaded from a CDN; D3/scrollama/topojson are npm-bundled).
- **`amanda-repository`**: Supabase URL + anon key remain committed in plaintext in `environment.ts` — the documented intended pattern (RLS is the real boundary). Live RLS policy correctness could not be verified from the repo alone (no schema file tracked); recommend confirming directly in the Supabase dashboard. Admin auth confirmed sound (`signInWithPassword`, no anon-key SELECT misuse). No XSS sinks found repo-wide.
- **`Calculator2.0`**: CDN scripts (`d3.v7.min.js`, `supabase-js` UMD bundle) still load without Subresource Integrity attributes, in both `index.html` and `admin.html` — unchanged from baseline.
- **`screenprops`**: `next.config.ts:12`'s CSP includes `'unsafe-eval'` in `script-src`. Not typically required for this stack and weakens XSS defense-in-depth versus `'unsafe-inline'` alone.
- **`screenprops`**: Running Next.js `16.2.6`, which per this repo's `AGENTS.md` is an explicitly non-standard/forked build — the version string doesn't correspond to a public Next.js release, so it cannot be checked against the known CVE list (SSRF-via-middleware, cache poisoning, image-optimization DoS, CSP-nonce bypass). Flagged as unverifiable rather than a confirmed issue.

---

## Repos With No Issues Found

- **`amandarae220` (profile)** — two cosmetic README commits since baseline; no secrets, no workflows, nothing else changed.
- **`dotfiles`** — clean aside from the resolved/informational items above; `.claude/` skill docs contain no remote-fetch-and-exec patterns, `install.sh` is a plain symlink installer.
- **`sudoku`** — clean beyond the resolved toolchain migration; no secrets, no XSS sinks, no new backend integrations.
- **`where-it-counts`** — clean beyond the unchanged latent `{@html}` note; dependency versions current, no secrets.

---

## Top Actions (ranked)

1. **Verify Supabase RLS on `screenprops`' `projects` table** (and the equivalent tables behind every platform-builder page) directly in the Supabase dashboard — this is the only unresolved finding carried across two consecutive scans, and nothing in the app code enforces it if RLS is off or misconfigured.
2. **Rotate the `neo-control` admin passphrase (the value formerly in `VITE_ADMIN_PASS`) anywhere it may be reused elsewhere** — it's permanently recoverable from git history even though the client-side gate that used it is gone.
3. Consider tightening `screenprops`' CSP by dropping `'unsafe-eval'` if nothing in the current dependency set requires it.
4. Add SRI hashes (or vendor locally) for the CDN-loaded D3/Supabase-JS scripts in `Calculator2.0` — flagged in two consecutive scans, still open.
5. Backfill `neo-control`'s `CONTEXT.md` commit log for the recent security-relevant commits so the project's self-maintained audit trail stays accurate.

No critical or high-severity issues remain open. The two prior HIGH findings (Calculator2.0 stored XSS, sudoku dependency toolchain) are both substantively fixed, not just patched over.
