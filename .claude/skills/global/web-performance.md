# Web Performance

Deep performance optimization: loading speed, runtime efficiency, resource optimization.

Use when asked to "speed up my site", "optimize performance", "reduce load time", "improve page speed", or "performance audit."

## Performance budgets

| Resource | Budget | Rationale |
|----------|--------|-----------|
| Total page weight | < 1.5 MB | 3G loads in ~4s |
| JavaScript (compressed) | < 300 KB | Parsing + execution time |
| CSS (compressed) | < 100 KB | Render blocking |
| Images (above-fold) | < 500 KB | LCP impact |
| Fonts | < 100 KB | FOIT/FOUT prevention |
| Third-party | < 200 KB | Uncontrolled latency |

## Critical rendering path

### Server response
- TTFB < 800ms. Use CDN, caching, optimized backends.
- Enable Brotli compression (15–20% smaller than gzip).
- HTTP/2 or HTTP/3 for multiplexing.
- Cache HTML at CDN edge when possible.
- **Early Hints (HTTP 103)**: when origin is slow, emit `103 Early Hints` with `Link: </hero.webp>; rel=preload; as=image` so the browser starts fetching before the 200 lands. Cloudflare reports 20–30% LCP improvements on image-heavy pages. Browsers that don't support 103 fall through safely. CDNs can synthesize 103s automatically.

### Resource loading

```html
<!-- Preconnect to required origins -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://cdn.example.com" crossorigin>

<!-- Preload LCP image -->
<link rel="preload" href="/hero.webp" as="image" fetchpriority="high">

<!-- Preload critical font -->
<link rel="preload" href="/font.woff2" as="font" type="font/woff2" crossorigin>
```

**Prerender likely-next navigations** with the Speculation Rules API:
```html
<script type="speculationrules">
{
  "prerender": [{
    "where": { "href_matches": "/*" },
    "eagerness": "moderate"
  }]
}
</script>
```
`moderate` triggers after ~200ms hover — captures most navigations without wasting bandwidth. Gate analytics/ads on `document.prerendering` — they fire at prerender time, not navigation time. Chromium-only; other browsers ignore it safely.

**Defer non-critical CSS:**
```html
<style>/* Critical above-fold CSS inlined */</style>
<link rel="preload" href="/styles.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="/styles.css"></noscript>
```

### JavaScript optimization

```html
<!-- ❌ Parser-blocking -->
<script src="/critical.js"></script>

<!-- ✅ Deferred (preferred) -->
<script defer src="/app.js"></script>

<!-- ✅ Async (independent scripts like analytics) -->
<script async src="/analytics.js"></script>

<!-- ✅ Modules are deferred by default -->
<script type="module" src="/app.mjs"></script>
```

**Code splitting:**
```javascript
// Route-based
const Dashboard = lazy(() => import('./Dashboard'));

// Component-based
const HeavyChart = lazy(() => import('./HeavyChart'));

// Feature-based
if (user.isPremium) {
  const PremiumFeatures = await import('./PremiumFeatures');
}
```

**Tree shaking:**
```javascript
// ❌ Imports entire library
import _ from 'lodash';

// ✅ Imports only what's needed
import debounce from 'lodash/debounce';
```

## Image optimization

### Format selection

| Format | Use case | Browser support |
|--------|----------|-----------------|
| AVIF | Photos, best compression | 92%+ |
| WebP | Photos, good fallback | 97%+ |
| PNG | Graphics with transparency | Universal |
| SVG | Icons, logos, illustrations | Universal |

### Responsive images

```html
<picture>
  <source type="image/avif"
    srcset="hero-400.avif 400w, hero-800.avif 800w, hero-1200.avif 1200w"
    sizes="(max-width: 600px) 100vw, 50vw">
  <source type="image/webp"
    srcset="hero-400.webp 400w, hero-800.webp 800w, hero-1200.webp 1200w"
    sizes="(max-width: 600px) 100vw, 50vw">
  <img
    src="hero-800.jpg"
    srcset="hero-400.jpg 400w, hero-800.jpg 800w, hero-1200.jpg 1200w"
    sizes="(max-width: 600px) 100vw, 50vw"
    width="1200" height="600"
    alt="Hero image"
    loading="lazy"
    decoding="async">
</picture>
```

### LCP image priority

```html
<!-- Above-fold LCP image: eager, high priority -->
<img src="hero.webp" fetchpriority="high" loading="eager" decoding="sync" alt="Hero">

<!-- Below-fold: lazy -->
<img src="product.webp" loading="lazy" decoding="async" alt="Product">
```

## Font optimization

```css
body {
  font-family: 'Custom Font', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

@font-face {
  font-family: 'Custom Font';
  src: url('/fonts/custom.woff2') format('woff2');
  font-display: swap;
  font-weight: 400;
  font-style: normal;
  unicode-range: U+0000-00FF; /* Subset to Latin */
}
```

Use variable fonts to replace multiple weight files:
```css
@font-face {
  font-family: 'Inter';
  src: url('/fonts/Inter-Variable.woff2') format('woff2-variations');
  font-weight: 100 900;
  font-display: swap;
}
```

Preload critical fonts:
```html
<link rel="preload" href="/fonts/heading.woff2" as="font" type="font/woff2" crossorigin>
```

## Caching strategy

```
# HTML: short or no cache
Cache-Control: no-cache, must-revalidate

# Static assets with content hash: immutable
Cache-Control: public, max-age=31536000, immutable

# Static assets without hash
Cache-Control: public, max-age=86400, stale-while-revalidate=604800

# API responses
Cache-Control: private, max-age=0, must-revalidate
```

## Runtime performance

**Avoid layout thrashing:**
```javascript
// ❌ Forces multiple reflows (interleaved read/write)
elements.forEach(el => {
  const height = el.offsetHeight; // read
  el.style.height = height + 10 + 'px'; // write
});

// ✅ Batch reads, then batch writes
const heights = elements.map(el => el.offsetHeight);
elements.forEach((el, i) => { el.style.height = heights[i] + 10 + 'px'; });
```

**Debounce expensive handlers:**
```javascript
function debounce(fn, delay) {
  let timeout;
  return (...args) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => fn(...args), delay);
  };
}
window.addEventListener('scroll', debounce(handleScroll, 100));
```

**Use requestAnimationFrame for animations:**
```javascript
// ❌ May cause jank
setInterval(animate, 16);

// ✅ Synced to display refresh
function animate() {
  // animation logic
  requestAnimationFrame(animate);
}
requestAnimationFrame(animate);
```

## Core Web Vitals impact

See `core-web-vitals.md` for targeted LCP, INP, and CLS optimization with measurement code.
