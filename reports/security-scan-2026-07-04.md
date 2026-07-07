# Security Scan — 2026-07-04

## Scope & Methodology

No prior `security-scan-*.md` report exists anywhere in this repo (checked `reports/` and full commit history) — **this is the first run of this recurring scan.** There is no baseline to diff against, so every accessible repository was scanned in full to establish one. Future runs should compare each repo's latest commit SHA against the checkpoint table below and only deep-scan repos with new commits since then.

Each repo was scanned (read-only, no files modified) for: exposed secrets/credentials (tracked + full git history), XSS-class injection risks, dependency vulnerabilities, insecure transport, and exposed/unauthenticated API surface.

## Repos Scanned — Checkpoint for Next Run

| Repo | Last Commit | Date | Owner |
|---|---|---|---|
| neo-control | `144f5d2` | 2026-06-23 | amandarae220 |
| dotfiles | `e763a29` | 2026-07-02 | amandarae220 |
| where-it-counts | `218684e` | 2026-07-01 | amandarae220 |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 | amandarae220 |
| amanda-repository | `131a77c` | 2026-06-18 | amandarae220 |
| Calculator2.0 | `3a4bcf9` | 2026-06-18 | amandarae220 |
| screenprops | `19fe372` | 2026-06-13 | amandarae220 |
| amandarae220 (profile) | `2bc6ffb` | 2026-05-29 | amandarae220 |
| doteon | `5413b63` | 2026-05-29 | amandarae220 |
| scamlessgames | `5303ffc` | 2026-05-23 | psmithskynativ |
| tamagotchi-game | `a322c7f` | 2026-04-22 | amandarae220 |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 | amandarae220 |
| sudoku | `a833819` | 2025-02-17 | amandarae220 |
| interactiveResume | `3e638ca` | 2024-07-28 | amandarae220 |
| habitTracker | `5b4aef4` | 2024-03-09 | amandarae220 |

15 of 15 accessible repos scanned. Findings: **2 critical, 5 high, 4 medium, 9 low/informational.**

---

## 🚨 Critical

**`neo-control` — live, currently-exploitable exposed credential**
`SECURITY [severity: critical]: CONTEXT.md:101 — Real admin passphrase committed in plaintext ("VITE_ADMIN_PASS # currently: [REDACTED]") in a tracked file — must be treated as compromised.`
- The value is a `VITE_`-prefixed env var, which Vite inlines into the public JS bundle regardless — so `AdminPage.tsx` also ships the same value client-side, and `sessions.ts` reads the `sessions` table with the public anon key with no server-side check. The password gate is cosmetic and trivially bypassed by calling the Supabase REST endpoint directly.
- **Action: rotate `VITE_ADMIN_PASS` now, remove the literal value from `CONTEXT.md`, and move real access control server-side (Supabase RLS scoped to an authenticated role) — a client-side string compare is not authorization.**

**`amanda-repository` — burned credential in git history (already remediated in current code)**
`SECURITY [severity: critical]: src/environments/environment.ts (history, commit 875772e) — Plaintext admin password "[REDACTED]" committed 2026-06-14.`
- This is the same finding the 2026-06-16 monthly audit already flagged. Since then the app moved auth to Supabase (`9dad430`) and the plaintext/hash no longer appear in the current file — but both the plaintext password and two unsalted SHA-256 hashes of it remain permanently retrievable via `git log --all -p`.
- **Action: treat this password as permanently burned (rotate anywhere reused); only purge history via `git filter-repo`/BFG if you're prepared to coordinate a force-push with any collaborators/forks.**
- Side note: `dotfiles/reports/audit-2026-06-16.md:13` quotes this same plaintext password verbatim — a second live copy of an already-compromised credential sitting in a different repo. Low severity on its own since the credential is already burned, but redact it in future report writeups.

## 🔴 High

- **`neo-control`**: `package-lock.json` — `react-router-dom` 7.14.2 and `vite` 8.0.9 pull in known-CVE versions (DoS via unbounded path expansion GHSA-8x6r-g9mw-2r78, CSRF GHSA-84g9-w2xq-vcv6, NTLMv2 hash disclosure GHSA-v6wh-96g9-6wx3). Run `npm audit fix` / bump both past their patched releases.
- **`Calculator2.0`**: `admin.html:551-552` — Stored XSS. `device`/`browser` values from the `calculator_events` Supabase table are concatenated straight into `innerHTML` for `<option>` tags. The table's RLS insert policy (`for insert to anon with check (true)`) lets any unauthenticated client write those fields via the public anon key, so an attacker can inject markup that executes in the admin's browser (and the admin session persists — `persistSession: true`). Fix: use `textContent`/`createElement` instead of string concatenation, and constrain `device`/`browser` with a DB-level allow-list/CHECK constraint.
- **`scamlessgames`**: `package.json:12` — `next@16.2.3` is flagged by `npm audit` for multiple CVEs (Server Components DoS, middleware/proxy bypass, cache poisoning, CSP-nonce XSS, image-optimization DoS, WebSocket-upgrade SSRF). Confirm the resolved release actually carries fixes, then `npm audit fix --force` (→16.2.10) after testing.
- **`tamagotchi-game`**: `package.json` — production Angular packages pinned at 21.2.9 are vulnerable to template/attribute namespace sanitization XSS bypass and dynamic-component namespace bypass XSS (both shipped to end users, not dev-only). Update to Angular 21.2.16+.
- **`sudoku`**: `npm audit` reports 57 vulnerabilities (2 critical, 24 high) in the `react-scripts`/CRA build toolchain (`shell-quote` shell-injection, `form-data` CRLF injection, `nth-check` ReDoS, `ws` DoS). All are dev/build-time only — not shipped in the production bundle — but the dev environment and CI runner are exposed. `react-scripts@5.0.1` is unmaintained; recommend migrating off CRA rather than chasing individual advisories.

## 🟡 Medium

- **`screenprops`**: Ownership scoping on the `projects` table (`.eq("user_id", user.id)`) is enforced only in client-side Supabase queries with the public anon key — no server-side route handlers or RLS policies are defined in-repo. If RLS on `projects` isn't enabled/correct in the live Supabase project, any authenticated user could edit the client query to read/modify/delete other users' data. Verify RLS in the Supabase dashboard; don't rely on client-supplied filters as the authorization boundary.
- **`interactiveResume`**: `index.html:12,14` — D3 v5 and d3-hexbin loaded from `d3js.org` with no Subresource Integrity attribute; a compromised CDN could serve altered JS with no detection. Add `integrity`/`crossorigin` hashes or vendor locally.
- **`dotfiles`**: same CDN-SRI-class issue doesn't apply here directly, but see the burned-credential note above under amanda-repository.
- **`neo-control`** (additional): `js-yaml` and `brace-expansion` transitive dev deps carry moderate DoS advisories — `npm audit fix`.

## 🟢 Low / Informational

- **`true-cost-of-car-ownership`**: Chart.js + datalabels plugin loaded from jsdelivr with no SRI (low — no exploitable injection path currently, static numeric-only inputs).
- **`where-it-counts`**: `Scrollytelling.svelte:51` uses `{@html step.text}` on currently-hardcoded static strings — not exploitable today, but would become XSS if step text is ever sourced from a CMS/API without sanitization. Switch to plain interpolation now to remove the latent risk.
- **`Calculator2.0`** (additional): CDN scripts (D3, Supabase JS) loaded without SRI.
- **`scamlessgames`**: dev-only transitive deps (`@babel/core`, `brace-expansion`, `js-yaml`, `postcss`) flagged by `npm audit`, no runtime exposure.
- **`doteon`**: `.next/` build output (153 files) is tracked in git — `.gitignore` doesn't exclude it. Not a leak today, but if a future build ever inlines a secret into a client bundle it would be silently committed. Add `.next` to `.gitignore` and untrack it.
- **`dotfiles`**: `git/gitconfig` globally rewrites `https://github.com/` → SSH for anyone who symlinks it — informational, changes auth behavior on install, not a vulnerability.
- **`amanda-repository`**: Supabase URL + anon key committed in plaintext — this is Supabase's intended public-client pattern (RLS is the real boundary); confirm RLS policies are airtight rather than rotating the key.
- **`neo-control`** (additional): Supabase anon key sourced correctly from `import.meta.env` per documented design decision — flagged only for awareness, not a fix.
- **`sudoku`**: overall build toolchain (CRA/`react-scripts`) is unmaintained — recommend a framework migration rather than chasing each advisory individually.

---

## Repos With No Issues Found

- **DungeonsAndDragons** — fully offline, no network calls, all dynamic `innerHTML` inserts go through an `escapeHTML()` helper.
- **habitTracker** — no CDN loads, no `innerHTML`, no secrets. (Has unrelated functional bugs — broken stylesheet reference, undefined `ajaxRequest` handler — not security issues.)
- **amandarae220 (profile)** — single README, no secrets, no workflows.

---

## Top Actions (ranked)

1. **Rotate `VITE_ADMIN_PASS` in `neo-control` immediately** and strip the literal value from `CONTEXT.md` — this is a live, currently-committed credential, not a historical one.
2. **Move `neo-control`'s admin gate server-side** (Supabase RLS / authenticated role) — the client-side password check is bypassable via the anon key regardless of the password value.
3. **Fix the stored-XSS path in `Calculator2.0`'s `admin.html`** — string-concatenated `innerHTML` fed by an unauthenticated-writable table is a real attacker-reachable chain, not a theoretical one.
4. Treat the `amanda-repository` plaintext password (and its two unsalted hashes) in git history as burned; rotate anywhere it was reused.
5. Run `npm audit fix` across `neo-control`, `scamlessgames`, and `tamagotchi-game` for the high-severity dependency CVEs; plan a toolchain migration for `sudoku` off unmaintained CRA.
