# Security Scan — 2026-07-05

## Scope Note

No prior `security-scan-*.md` report exists in this repo (only the rotating `audit-*.md` quality/a11y reports, most recent `audit-2026-06-30.md`). This is treated as the **baseline run** for this routine — all 15 accessible repos were checked rather than a delta since a prior security scan. Future runs should diff against this file's date.

## Repos Scanned (15) — Last Update Time

| Repo | Last Commit | Notes |
|---|---|---|
| dotfiles | 2026-07-02 | |
| where-it-counts | 2026-07-01 | |
| true-cost-of-car-ownership | 2026-06-30 | |
| neo-control | 2026-06-23 | |
| amanda-repository | 2026-06-18 | |
| Calculator2.0 | 2026-06-18 | |
| screenprops | 2026-06-13 | |
| amandarae220 (profile) | 2026-05-29 | |
| doteon | 2026-05-29 | |
| scamlessgames | 2026-05-23 | (psmithskynativ/scamlessgames) |
| tamagotchi-game | 2026-04-22 | |
| DungeonsAndDragons | 2025-12-05 | |
| sudoku | 2025-02-17 | |
| interactiveResume | 2024-07-28 | |
| habitTracker | 2024-03-09 | |

Every repo had commits predating this scan, so all were checked in full (no repo was skipped as "already scanned").

---

## Findings by Severity

### 🚨 Critical

**neo-control — live admin passphrase committed in plaintext**
`CONTEXT.md:101` reads `VITE_ADMIN_PASS # currently: checkadmininsights` — the actual, current password for the `/admin` analytics dashboard is committed to the repo, under a section literally titled "Environment Variables (never commit)". Compounding this, `src/pages/AdminPage.tsx:4` reads `import.meta.env.VITE_ADMIN_PASS` and checks it client-side, so the same password is also baked into the production JS bundle. This means the admin dashboard has no real access control — the password is readable both from the repo and from the deployed site's source. This exact issue was first flagged as critical in the `audit-2026-06-26.md` report (9 days ago) and is still unresolved.
**Fix:** Rotate the password immediately (it must be treated as burned), remove it from `CONTEXT.md` entirely, and move auth to a server-side check (Supabase Edge Function or similar) — never ship the passphrase in a `VITE_`-prefixed env var.

### 🔴 High

**Calculator2.0 — likely stored XSS in admin dashboard via unescaped `innerHTML`**
`admin.html:551-552` builds `<option>` elements via string concatenation and assigns them with `innerHTML` using `device`/`browser` values pulled from the shared `portfolio_events` Supabase table:
```js
deviceSel.innerHTML  = '<option value="">All devices</option>'  + devices.map(d => '<option>' + d + '</option>').join('');
```
That table is written to by anyone holding the public Supabase anon key (embedded client-side in both `amanda-repository` and `Calculator2.0`), via direct REST calls that bypass the app's own `getDevice()`/`getBrowser()` parsing. An attacker can insert a crafted `device` string (e.g. `<img src=x onerror=...>`) directly through the Supabase API, and it will execute in the site owner's browser the next time they view `admin.html`.
**Fix:** Escape values before inserting into the DOM (use `textContent`/`option.text =` instead of string-built `innerHTML`), and confirm Row Level Security on `portfolio_events` restricts writes to expected shapes.

**neo-control — react-router / react-router-dom, 2 high-severity CVEs**
`npm audit`: DoS via unbounded path expansion (`GHSA-8x6r-g9mw-2r78`) and potential CSRF via PUT/PATCH/DELETE document requests (`GHSA-84g9-w2xq-vcv6`) in `react-router 7.0.0–7.15.0`. Fix available via `npm audit fix`.

**tamagotchi-game — Angular XSS sanitization bypass, 7 high-severity CVEs**
`npm audit`: `@angular/compiler`/`@angular/core`/`@angular/animations` (21.0.0-next.0–21.2.16) have two-way binding and template/attribute namespace sanitization bypass vulnerabilities (`GHSA-58w9-8g37-x9v5`, `GHSA-f3m7-gqxr-g87x`). Fix available via `npm audit fix`.

### 🟡 Medium

**doteon — `.next` build output committed to git (153 files)**
`.gitignore` only excludes `node_modules`; the compiled `.next/` directory is fully tracked. Checked the committed bundle for baked-in secrets (env values, service-role keys) — found none this time, only a harmless reference to an env var *name*. Still a real ongoing risk: any secret accidentally present at build time would get committed verbatim with no review, and it bloats the repo with stale, regeneratable artifacts.
**Fix:** Add `.next/` to `.gitignore` and remove the tracked copy (`git rm -r --cached .next`).

**doteon, scamlessgames, screenprops — outdated Next.js with known CVEs**
`npm audit` on all three flags moderate/high issues via outdated `next`/`postcss`: CSS-stringify XSS (`GHSA-qx2v-qp2m-jg93`, moderate, all three), plus for doteon specifically — Image Optimization DoS, WebSocket-upgrade SSRF, RSC cache poisoning, and an i18n middleware bypass; scamlessgames has a middleware/proxy bypass via route-param injection and segment-prefetch routes. Fixes require a major-version bump (`next@16.x`) — breaking change, needs a scheduled upgrade rather than `--force` in place.

**amanda-repository / Calculator2.0 — Supabase anon key + URL committed in source**
`amanda-repository/src/environments/environment.ts` and `Calculator2.0/admin.html` both embed a live Supabase project URL and anon key. This is standard/expected for Supabase (the anon key is meant to be public) *provided* Row Level Security policies on the underlying tables are airtight — this was flagged for verification in the `audit-2026-06-16.md` report and no RLS documentation exists in either repo to confirm it was checked. Given the stored-XSS path above, this is worth re-verifying now rather than assuming it's fine.

### 🟢 Low

**sudoku — 57 npm audit findings incl. 2 flagged "critical" (form-data, shell-quote)**
Confirmed these all live inside `react-scripts` (Create React App) build tooling — `webpack-dev-server`, `ws`, `yaml`, `shell-quote`, `form-data` are dev/build-time transitive deps, not part of the shipped production bundle. Real-world exploitability is low since the dev server isn't deployed. That said, CRA itself is deprecated and unmaintained — recommend migrating to Vite at some point rather than continuing to patch around it.

**Calculator2.0 — deploy workflow still checks out a deleted branch**
`.github/workflows/deploy.yml` checks out `feature/angular-makeover`, which was merged and deleted. This was already flagged in `audit-2026-06-16.md` and appears unfixed — deploys triggered by this workflow are likely failing silently, which isn't itself a vulnerability but means the live site may be running stale content without anyone noticing.

---

## Repos With No Issues Found

- **where-it-counts** — `npm audit`: 0 vulnerabilities. No secrets. Static site, no untrusted-input rendering paths.
- **true-cost-of-car-ownership** — static, no dependencies, no secrets; `innerHTML` usage confined to locally computed chart insight text.
- **DungeonsAndDragons** — no dependencies; `innerHTML` usage is local single-player game state, several sites already use an `escapeHTML()` helper.
- **interactiveResume** — no dependencies; `innerHTML` usage renders only hardcoded resume content.
- **habitTracker** — no dependencies, no secrets (a11y/quality issues were already covered in `audit-2026-06-30.md`, not repeated here).
- **amandarae220** (profile README repo) — no code surface to speak of.
- **screenprops** — no hardcoded secrets; Supabase client/server setup uses env vars correctly; only issue is the shared moderate Next.js/postcss CVE noted above.
- **amanda-repository** — `npm audit`: 0 vulnerabilities. The critical hardcoded admin password from `audit-2026-06-16.md` has been fixed (auth now goes through `supabase.auth.signInWithPassword`, not a plaintext client-side check).

---

## Priority Action List

1. **[CRITICAL]** Rotate the neo-control admin password now and strip it from `CONTEXT.md` — it has been sitting in plaintext in the repo for ~3 weeks.
2. **[HIGH]** Fix the unescaped `innerHTML` rendering in `Calculator2.0/admin.html` before it's exploited via the public Supabase write path.
3. **[HIGH]** Run `npm audit fix` in `neo-control` (react-router) and `tamagotchi-game` (Angular) — both have straightforward, non-breaking fixes available.
4. **[MEDIUM]** Untrack `.next/` in doteon and add it to `.gitignore`.
5. **[MEDIUM]** Schedule the Next.js major-version upgrade for doteon and scamlessgames to clear the outstanding CVEs.
