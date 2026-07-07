# Web Best Practices

Modern web standards: security headers, browser compatibility, deprecated APIs, runtime patterns.

Use when asked to "apply best practices", "modernize code", "browser compat audit", or "check for vulnerabilities."

> For input handling, secrets, auth, and dependency rules → see `security.md`.

---

## Security headers

### Content Security Policy (CSP)

```
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'nonce-abc123' https://trusted.com;
  style-src 'self' 'nonce-abc123';
  img-src 'self' data: https:;
  connect-src 'self' https://api.example.com;
  frame-ancestors 'self';
  base-uri 'self';
  form-action 'self';
```

Use nonces for inline scripts:
```html
<script nonce="abc123">/* this inline script is allowed */</script>
```

Use `frame-ancestors 'self'` in CSP instead of `X-Frame-Options: DENY` — CSP is the modern standard.

### Trusted Types (DOM-XSS defense)

A strict CSP blocks untrusted *script files* but doesn't stop a string from reaching `innerHTML`, `eval`, or other DOM sinks. Trusted Types — Baseline across all major browsers since early 2026 — closes that gap:

```
Content-Security-Policy: require-trusted-types-for 'script'; trusted-types default;
```

```javascript
const escape = trustedTypes.createPolicy('default', {
  createHTML: (s) => DOMPurify.sanitize(s, { RETURN_TRUSTED_TYPE: true })
});

// ❌ Throws TypeError under enforcement
element.innerHTML = userInput;

// ✅ Goes through the policy
element.innerHTML = escape.createHTML(userInput);
```

Roll out with `Content-Security-Policy-Report-Only` first to find every sink, then flip to enforcement. Angular has built-in Trusted Types support; React 19+ produces TrustedHTML under enforcement.

### Subresource Integrity (SRI)

Pin every `<script>` and `<link rel="stylesheet">` from a CDN you don't control:

```html
<script src="https://cdn.example.com/lib@1.2.3/dist/lib.js"
        integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC"
        crossorigin="anonymous"></script>
```

Generate: `openssl dgst -sha384 -binary file.js | openssl base64 -A`. SRI requires `crossorigin` and `Access-Control-Allow-Origin` from the CDN.

**Never load polyfills from polyfill.io** — it was compromised in 2024 and served malware to ~100k sites. Self-host or use a vetted CDN mirror (e.g., Cloudflare's cdnjs build) and pin with SRI.

### HTTPS

```html
<!-- ❌ Mixed content -->
<img src="http://example.com/image.jpg">

<!-- ✅ HTTPS only -->
<img src="https://example.com/image.jpg">
```

Avoid protocol-relative URLs (`//example.com/...`) — they hide the scheme and have no benefit on HTTPS-only sites.

HSTS:
```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

### Other security headers

```
X-Content-Type-Options: nosniff
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

Do NOT set `X-XSS-Protection`. The legacy browser XSS auditor was removed (Chrome 78, Edge 17) and introduced its own vulnerabilities. Use CSP + Trusted Types instead.

---

## Browser compatibility

### HTML basics

```html
<!-- ✅ Correct document structure -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Page Title</title>
</head>
```

- `<!DOCTYPE html>` first
- `<meta charset="UTF-8">` as first element in `<head>`
- Viewport meta tag required for mobile

### Feature detection over browser sniffing

```javascript
// ❌ Browser detection (brittle)
if (navigator.userAgent.includes('Chrome')) { /* ... */ }

// ✅ Feature detection
if ('IntersectionObserver' in window) {
  // use IntersectionObserver
} else {
  // fallback
}
```

```css
@supports (display: grid) {
  .container { display: grid; }
}
@supports not (display: grid) {
  .container { display: flex; }
}
```

### Polyfills

Prefer bundling polyfills at build time (Babel/SWC + `core-js`, or `@vitejs/plugin-legacy`) targeted at your supported-browsers list. This eliminates runtime checks and avoids shipping bytes to modern browsers.

If loading at runtime, append a script element — never `document.write`:
```html
<script>
  if (!('fetch' in window)) {
    const s = document.createElement('script');
    s.src = '/polyfills/fetch.js';
    s.defer = true;
    document.head.appendChild(s);
  }
</script>
```

---

## Deprecated APIs — avoid these

```javascript
// ❌ document.write (blocks parser, broken in async contexts)
document.write('<script src="..."></script>');
// ✅
const script = document.createElement('script');
script.src = '...';
document.head.appendChild(script);

// ❌ Synchronous XHR (blocks main thread)
const xhr = new XMLHttpRequest();
xhr.open('GET', url, false);
// ✅
const response = await fetch(url);

// ❌ Application Cache (deprecated)
<html manifest="cache.manifest">
// ✅
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js');
}
```

**Passive event listeners** — required for smooth scroll/touch:
```javascript
// ❌ May block scrolling
element.addEventListener('touchstart', handler);

// ✅ Passive (allows smooth scrolling)
element.addEventListener('touchstart', handler, { passive: true });
element.addEventListener('wheel', handler, { passive: true });

// If you must preventDefault, be explicit
element.addEventListener('touchstart', handler, { passive: false });
```

---

## Source maps

```javascript
// ❌ Source maps exposed in production (exposes your source code)
// webpack.config.js
devtool: 'source-map'

// ✅ Hidden source maps (upload to error tracker, not served publicly)
devtool: 'hidden-source-map'

// Vite
build: { sourcemap: 'hidden' }
```

**Strip `sourcesContent`** when uploading to Sentry/Bugsnag. By default bundlers embed the full original source inside `.map` files — anyone who obtains the map gets your unminified code. Configure your bundler to omit `sourcesContent`, or use the error tracker CLI flag.

---

## Prototype pollution defense

```javascript
// ❌ Deep merge of untrusted input can pollute Object.prototype
_.merge(target, userInput);        // lodash < 4.17.20
$.extend(true, {}, userInput);     // jQuery deep extend with untrusted input

// ✅ Use null-prototype object for untrusted bags
const safe = Object.create(null);
Object.assign(safe, userInput);    // shallow, safe by construction

// ✅ Deep copy that drops __proto__ and functions
const deepSafe = structuredClone(userInput);
```

---

## Runtime patterns

**Event delegation** (efficient, handles dynamic content):
```javascript
// ❌ Handler on every element
items.forEach(item => item.addEventListener('click', handleClick));

// ✅ Single delegated handler
container.addEventListener('click', (e) => {
  if (e.target.matches('.item')) handleClick(e);
});
```

**Memory cleanup:**
```javascript
// ✅ Use AbortController for event cleanup
const controller = new AbortController();
window.addEventListener('resize', handler, { signal: controller.signal });
// cleanup:
controller.abort();
```

**Error handling:**
```javascript
// Global error handler
window.addEventListener('error', (e) => errorTracker.captureException(e.error));
window.addEventListener('unhandledrejection', (e) => errorTracker.captureException(e.reason));
```

---

## Checklist

### Security (critical)
- [ ] HTTPS; no mixed content
- [ ] `npm audit` — no critical/high vulnerabilities
- [ ] CSP headers configured (`frame-ancestors`, `base-uri`, `form-action`)
- [ ] `require-trusted-types-for 'script'` enforced (or report-only during rollout)
- [ ] Third-party `<script>`/`<link>` pinned with SRI hashes
- [ ] HSTS, `X-Content-Type-Options`, `Referrer-Policy` set
- [ ] Hidden source maps; `sourcesContent` stripped from uploads

### Compatibility
- [ ] Valid `<!DOCTYPE html>`
- [ ] Charset declared first in `<head>`
- [ ] Viewport meta tag present
- [ ] No deprecated APIs (`document.write`, sync XHR)
- [ ] Passive event listeners for scroll/touch

### Code quality
- [ ] No console errors in production
- [ ] Valid HTML (no duplicate IDs, no invalid nesting)
- [ ] Semantic HTML elements
- [ ] Global error handler present
- [ ] Memory cleanup in components (AbortController or removeEventListener)
