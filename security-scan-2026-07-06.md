# Security Scan — 2026-07-06

## Scan Baseline

No prior `security-scan-*.md` report exists in this repo (only unrelated monthly `reports/audit-*.md` code-quality/a11y audits, which rotate through 2 repos at a time and aren't a security-scan baseline). This is treated as the **first run** of this routine: all 15 accessible repos were scanned in full to establish the baseline. Future runs should scan only repos with commits after 2026-07-06.

## Repos Scanned & Last Update

| Repo | Last Commit | Last Commit Date |
|---|---|---|
| dotfiles | `e763a29` | 2026-07-02 |
| where-it-counts | `218684e` | 2026-07-01 |
| true-cost-of-car-ownership | `21dfc2d` | 2026-06-30 |
| neo-control | `144f5d2` | 2026-06-23 |
| amanda-repository | `131a77c` | 2026-06-18 |
| Calculator2.0 | `3a4bcf9` | 2026-06-18 |
| screenprops | `19fe372` | 2026-06-13 |
| amandarae220 | `2bc6ffb` | 2026-05-29 |
| doteon | `5413b63` | 2026-05-29 |
| scamlessgames | `5303ffc` | 2026-05-23 |
| DungeonsAndDragons | `3ae9643` | 2025-12-05 |
| tamagotchi-game | `a322c7f` | 2026-04-22 |
| sudoku | `a833819` | 2025-02-17 |
| interactiveResume | `3e638ca` | 2024-07-28 |
| habitTracker | `5b4aef4` | 2024-03-09 |

---

## Findings by Severity

### 🔴 Critical (1)

- **amanda-repository** — `src/environments/environment.prod.ts` (deleted from working tree, but permanently present in git history at commit `e629393`, 2026-06-14): hardcoded plaintext `adminPassword: 'admininsights'`. Admin auth has since moved to Supabase Auth, but the plaintext password is still readable by anyone who clones the repo or views its history on GitHub. **Action:** rotate this password (and anywhere it may have been reused), and consider scrubbing it from history with `git filter-repo`/BFG if the repo is or was public.

### 🟠 High (3)

- **neo-control** — `src/pages/AdminPage.tsx:1066-1068`: admin gate is a client-side string comparison against `import.meta.env.VITE_ADMIN_PASS`. Vite inlines `VITE_`-prefixed vars into the shipped bundle, so the real admin passphrase ships in plaintext in `dist` — trivially extractable via devtools. **Action:** move this check server-side (Supabase edge function / RLS-gated request).
- **neo-control** — `react-router-dom@7.14.2`: two known advisories (DoS via unbounded path expansion on the `__manifest` endpoint; CSRF via PUT/PATCH/DELETE document requests). **Action:** `npm audit fix` / upgrade to the patched 7.15.x line.
- **Calculator2.0** — `admin.html:551-552`: `deviceSel.innerHTML`/`browserSel.innerHTML` are built by concatenating `device`/`browser` values pulled unescaped from the `calculator_events` Supabase table. That table's RLS policy allows **any anonymous client** to INSERT arbitrary rows (`with check (true)`, no column validation) using the public anon key already exposed in `assets/config.js`. Net effect: an attacker can POST a crafted `device`/`browser` field (e.g. `<img src=x onerror=...>`) straight to the Supabase REST endpoint, producing **stored XSS in the admin dashboard** the next time the site owner opens it. **Action:** switch those two lines to `textContent`/DOM construction like the rest of the file already does, and/or add server-side validation on the insert policy.

### 🟡 Medium (7)

- **screenprops** — No server-side authorization exists beyond a login redirect in `proxy.ts`; `DashboardClient.tsx:41` deletes rows filtered only by client-supplied `user.id`. This is safe only if Supabase RLS is actually enforced on the `projects` table — unverifiable from source. **Action:** confirm RLS policies are live; if not, this is an IDOR (would escalate to High).
- **neo-control** — Same category: Supabase access relies on RLS being correctly configured server-side; not verifiable from the repo alone. **Action:** confirm RLS policies.
- **amanda-repository** — The recent "tightening gitignore" commit is solid going forward (adds `.env*`, `*.pem`, `*.key`, credentials/service-account patterns) but does nothing to purge the already-committed admin password (see Critical, above), and there's no gitleaks/pre-commit secret-scanning in place to catch recurrence.
- **true-cost-of-car-ownership** — `index.html:10-11`: Chart.js and Google Fonts loaded from CDN with no Subresource Integrity (SRI) hash. A compromised CDN artifact would execute unverified in every visitor's browser.
- **interactiveResume** — `index.html:12,14`: D3 v5 and d3-hexbin loaded from `d3js.org` with no SRI hash; D3 v5 is also several majors behind current (v7).
- **doteon** — `.next/` build output (including webpack cache) is committed to git despite `.gitignore` only excluding `node_modules`. Hygiene issue that risks leaking build-time values if env vars are ever introduced, and bloats the repo.
- **sudoku** — Dependency staleness (stale since Feb 2025): `nth-check@1.0.2` (transitive via react-scripts→svgo) has a ReDoS advisory (GHSA-rp65-9cf3-cjxr); `webpack-dev-server@4.15.2` has a dev-time source-exposure advisory, fixed in 5.2.0+. Both are Create-React-App-era, now-unmaintained tooling.

### 🟢 Low (7)

- **dotfiles** — `shell/zshrc:105` `killport()` pipes `$1` into `xargs kill -9` unsanitized; low risk in a personal-use shell function.
- **where-it-counts** — `Scrollytelling.svelte:51` uses `{@html step.text}`; currently safe (all values are hardcoded narrative strings, not user/CMS input) but a latent XSS sink if that data source ever changes.
- **true-cost-of-car-ownership** — `index.html:2401,2414` build `innerHTML` from slider-derived values only; safe today but fragile if a free-text input is ever added.
- **screenprops** — CSP includes `'unsafe-inline' 'unsafe-eval'` in `script-src`, weakening XSS defense-in-depth.
- **scamlessgames** — `next.config.ts` has no explicit `headers()` — no CSP/HSTS/X-Frame-Options configured (relies on Next.js defaults only). No backend/API routes exist, so impact is currently low.
- **DungeonsAndDragons** — `index.html:1266` `setDialogStatus()` skips the repo's own `escapeHTML()` helper; not currently exploitable (no free-text inputs exist). Separately, enemy HP is written into the DOM whenever the combat feed renders, readable via devtools regardless of UI-level hiding — expected for a client-only game, noted for completeness.
- **Calculator2.0 / amanda-repository** — Supabase anon keys committed in `assets/config.js` / `environment.ts` are intentional-by-design (RLS is the stated security boundary) — flagged low since their safety is entirely contingent on RLS actually being configured correctly (see Medium items above).

---

## Repos With No Issues

- **amandarae220** (GitHub profile README) — no secrets, no workflows, only intentionally public contact info.
- **tamagotchi-game** — clean; Angular templating auto-escapes, no secrets, no unsafe sinks. Recommend a live `npm audit` run as routine hygiene (not executed in this static pass).
- **habitTracker** — clean; no secrets, no CDN deps, no `innerHTML` usage (uses `innerText` throughout).

---

## Top Priorities

1. **Rotate `admininsights`** (amanda-repository) and evaluate scrubbing it from git history.
2. **Fix the Calculator2.0 admin.html stored-XSS path** — switch `innerHTML` → `textContent` for `device`/`browser` fields (exploitable today via the open anon-key insert policy).
3. **Move neo-control's admin gate server-side** — the current client-side password check is not a real gate.
4. **Confirm Supabase RLS is actually enforced** on screenprops (`projects` table) and neo-control — several "safe by design" findings above depend entirely on this being true.
5. **Patch neo-control's react-router-dom** to the version with the DoS/CSRF advisories fixed.
