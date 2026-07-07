# Web Quality Audit

Comprehensive quality review covering Performance, Accessibility, SEO, and Best Practices.

Use when asked to "audit my site", "review web quality", "run a Lighthouse audit", or "check page quality."

> **Lighthouse v13 note (Oct 2025+).** The Performance category moved to Performance Insight Audits. Individual audits like *First Meaningful Paint*, *No Document Write*, *Uses Passive Event Listeners* were removed or merged. The underlying advice still applies — only the report format changed. CLS audits are now `cls-culprits-insight`; image audits are `image-delivery-insight`. Treat older Lighthouse JSON as a superset.

## How to audit

1. Analyze code/project for quality issues
2. Categorize findings by severity (Critical, High, Medium, Low)
3. Provide specific, actionable recommendations with code examples

## Audit categories

### Performance (40% of typical issues)

**Core Web Vitals** — must pass:
- LCP < 2.5s: optimize images, fonts, server response time
- INP < 200ms: reduce JS execution, break up long tasks
- CLS < 0.1: set explicit dimensions on images, embeds, ads

**Resource optimization:**
- Images: WebP/AVIF with fallbacks, correct size via `srcset`
- JS: remove unused code, code splitting, defer non-critical scripts
- CSS: extract critical CSS, remove unused styles, avoid `@import`
- Fonts: `font-display: swap`, preload critical fonts, subset characters

**Loading strategy:**
- `<link rel="preconnect">` for third-party domains
- Preload LCP images and critical fonts
- Lazy load below-fold images and iframes
- Immutable cache headers for hashed static assets

See `web-performance.md` and `core-web-vitals.md` for specifics.

### Accessibility (30% of typical issues)

- Every `<img>` has meaningful `alt` text; decorative images use `alt=""`
- Color contrast ≥ 4.5:1 normal text, ≥ 3:1 large text (WCAG AA)
- All functionality accessible via keyboard; no keyboard traps
- Visible focus indicators on all interactive elements
- "Skip to main content" skip link
- `lang` attribute on `<html>`
- All form inputs have associated labels; errors clearly described
- No duplicate IDs; valid HTML; ARIA roles match behavior

See `accessibility.md` for Amanda-specific patterns and gotchas.

### SEO (15% of typical issues)

- Valid `robots.txt`; doesn't block important resources
- XML sitemap exists and is submitted to Search Console
- Canonical URLs set on all pages
- Unique title tags (50–60 chars)
- Meta descriptions (150–160 chars)
- Single `<h1>` with logical heading hierarchy
- Mobile-responsive; tap targets ≥ 48px
- JSON-LD structured data for Article, Product, FAQ pages

See `seo.md` for full technical + on-page + structured data coverage.

### Best practices (15% of typical issues)

- No mixed content; HSTS enabled
- No vulnerable dependencies (`npm audit`)
- CSP headers; `require-trusted-types-for 'script'`
- Third-party `<script>` pinned with SRI hashes
- No deprecated APIs (`document.write`, synchronous XHR)
- Valid `<!DOCTYPE html>`, charset declared first in `<head>`
- No console errors in production; global error handler present
- Source maps hidden (`hidden-source-map`), `sourcesContent` stripped

See `web-best-practices.md` for full browser compat and security headers. See `security.md` for input handling, secrets, and auth rules.

## Severity levels

| Level | Description | Action |
|-------|-------------|--------|
| Critical | Security vulnerabilities, complete failures | Fix immediately |
| High | Core Web Vitals failures, major a11y barriers | Fix before launch |
| Medium | Performance opportunities, SEO improvements | Fix within sprint |
| Low | Minor optimizations, code quality | Fix when convenient |

## Audit output format

```markdown
## Audit results

### Critical issues (X found)
- **[Category]** Issue description. File: `path/to/file.js:123`
  - **Impact:** Why this matters
  - **Fix:** Specific code change or recommendation

### High priority (X found)
...

### Summary
- Performance: X issues (Y critical)
- Accessibility: X issues (Y critical)
- SEO: X issues
- Best Practices: X issues

### Recommended priority
1. First fix this because...
2. Then address...
```

## Pre-deploy checklist

- [ ] Core Web Vitals passing (Lighthouse or PageSpeed Insights)
- [ ] No accessibility errors (axe, Lighthouse, or manual keyboard test)
- [ ] No console errors
- [ ] `npm audit` clean (no critical/high vulnerabilities)
- [ ] HTTPS working; no mixed content
