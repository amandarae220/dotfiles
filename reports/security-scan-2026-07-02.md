# Daily Security Scan — 2026-07-02

## Scope Note

This is the first run of the `security-scan-*` daily routine — no prior `security-scan-*.md` baseline exists in `reports/`. In the absence of one, the most recent prior review (`reports/audit-2026-06-30.md`) was used as the cutoff: any repo with commits on or after **2026-06-30** was scanned in full. All later runs of this routine should diff against this report's date going forward.

## 1. Repos Scanned (updated since 2026-06-30)

| Repo | Last Commit | Last Commit Message |
|---|---|---|
| `dotfiles` | 2026-07-02 01:15 UTC | "adding new skills" |
| `where-it-counts` | 2026-07-01 18:15 UTC | Merge PR #5 (feature/reordering) |
| `true-cost-of-car-ownership` | 2026-06-30 03:57 UTC | "second chart's animation added" |

## 2. Repos Skipped (no changes since 2026-06-30)

| Repo | Last Commit |
|---|---|
| `neo-control` | 2026-06-23 |
| `amanda-repository` | 2026-06-18 |
| `Calculator2.0` | 2026-06-18 |
| `screenprops` | 2026-06-13 |
| `amandarae220` | 2026-05-29 |
| `doteon` | 2026-05-29 |
| `scamlessgames` | 2026-05-23 |
| `tamagotchi-game` | 2026-04-22 |
| `DungeonsAndDragons` | 2025-12-05 |
| `sudoku` | 2025-02-17 |
| `interactiveResume` | 2024-07-28 |
| `habitTracker` | 2024-03-09 |

No detailed scan performed on these 12 — nothing changed to introduce new risk since the last review.

---

## 3. Findings by Severity

### 🚨 Critical / 🔴 High
None found in any scanned repo.

### 🟡 Medium

- **SECURITY** `true-cost-of-car-ownership/index.html:10` — Chart.js 4.4.0 loaded from jsdelivr CDN with no Subresource Integrity (SRI) hash — if the CDN or upstream package were compromised, injected JS would run on the page unchecked — fix: add `integrity="sha384-..."` + `crossorigin="anonymous"` (jsdelivr provides hashes per-version).
- **SECURITY** `true-cost-of-car-ownership/index.html:11` — `chartjs-plugin-datalabels@2.2.0` CDN script has the same missing-SRI issue — same fix.

### 🟢 Low

- `true-cost-of-car-ownership/index.html:2401,2414` — `innerHTML` sinks (`dep-insight`, `gap-insight`) interpolate only numeric values from range-slider inputs — not exploitable today, but a `textContent`/DOM-building rewrite would remove the raw-HTML sink entirely if the app ever gains a free-text field.
- `true-cost-of-car-ownership/index.html:10` — Chart.js pinned to 4.4.0, one minor behind latest 4.5.x — no known CVE, just staleness.
- `where-it-counts/src/lib/components/Scrollytelling.svelte:51` — `{@html step.text}` renders a hardcoded prose array today (no user input reaches it), but is a latent stored-XSS sink if that array is ever externalized — swap to plain `{step.text}` since no current string needs raw HTML.
- `dotfiles/git/gitconfig:16` — `commit.gpgsign = false` — weakens commit provenance verification; not urgent for a personal dotfiles repo.
- `dotfiles/vscode/settings.json:63,86` — `explorer.confirmDelete: false`, `git.confirmSync: false` — mildly raises accidental-data-loss risk via the VS Code UI; informational only.

---

## 4. Repos With No Issues

- `where-it-counts` — no secrets, no dependency vulnerabilities (`npm audit` clean), no insecure resource loading, no CI exposure (no workflows exist). One low-severity hardening note above.
- `dotfiles` — no secrets, no shell-injection patterns, no insecure install/download flow, no overly-broad Claude Code permissions. Two low-severity informational notes above.
- `true-cost-of-car-ownership` — no secrets, no exploitable XSS path, no localStorage/cookie data exposure. Two medium (missing SRI) and a few low findings above are the only items.

---

## 5. Recommended Actions

1. **[MEDIUM]** Add SRI hashes to the two CDN `<script>` tags in `true-cost-of-car-ownership/index.html:10-11`.
2. **[LOW]** Replace `{@html step.text}` with plain interpolation in `where-it-counts/src/lib/components/Scrollytelling.svelte:51` to remove an unused raw-HTML sink.
3. No action required on the other findings — informational/staleness only.
