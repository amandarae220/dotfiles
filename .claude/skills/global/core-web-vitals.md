# Core Web Vitals

Targeted optimization for the three metrics that affect Google Search ranking and user experience.

Use when asked to "improve Core Web Vitals", "fix LCP", "reduce CLS", "optimize INP", or "fix layout shifts."

## The three metrics

| Metric | Measures | Good | Needs work | Poor |
|--------|----------|------|------------|------|
| **LCP** | Loading | ≤ 2.5s | 2.5s–4s | > 4s |
| **INP** | Interactivity | ≤ 200ms | 200ms–500ms | > 500ms |
| **CLS** | Visual stability | ≤ 0.1 | 0.1–0.25 | > 0.25 |

Google measures at the **75th percentile** — 75% of page visits must hit "Good."

---

## LCP: Largest Contentful Paint

LCP measures when the largest visible element renders (usually hero image, large text block, or background image).

### Common LCP issues

**Slow server response (TTFB > 800ms)**
Fix: CDN, caching, optimized backend, edge rendering.

**Render-blocking resources**
```html
<!-- ❌ Blocks rendering -->
<link rel="stylesheet" href="/all-styles.css">

<!-- ✅ Critical CSS inlined, rest deferred -->
<style>/* Critical above-fold CSS */</style>
<link rel="preload" href="/styles.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
```

**LCP image discovered late**
```html
<!-- ❌ No hints -->
<img src="/hero.jpg" alt="Hero">

<!-- ✅ Preloaded with high priority -->
<link rel="preload" href="/hero.webp" as="image" fetchpriority="high">
<img src="/hero.webp" alt="Hero" fetchpriority="high">
```

**Client-side rendering delays**
```javascript
// ❌ Content loads after JavaScript
useEffect(() => {
  fetch('/api/hero-text').then(r => r.json()).then(setHeroText);
}, []);

// ✅ Server-side or static rendering
export async function getServerSideProps() {
  const heroText = await fetchHeroText();
  return { props: { heroText } };
}
```

**Prerender likely-next navigations** — the LCP a user actually experiences is usually on the *next page*, not the landing page. Collapsing navigation LCP to ~0ms:
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
`moderate` starts after ~200ms hover — intent-correlated, rarely wasted. Gate analytics/ads on `document.prerendering` (they fire at prerender time). Chromium-only; others ignore it safely.

### LCP identification
```javascript
new PerformanceObserver((list) => {
  const entries = list.getEntries();
  const lastEntry = entries[entries.length - 1];
  console.log('LCP element:', lastEntry.element);
  console.log('LCP time:', lastEntry.startTime);
}).observe({ type: 'largest-contentful-paint', buffered: true });
```

### LCP checklist
- [ ] TTFB < 800ms
- [ ] LCP image preloaded with `fetchpriority="high"`
- [ ] LCP image optimized (WebP/AVIF, correct size)
- [ ] Critical CSS inlined (< 14KB)
- [ ] No render-blocking JavaScript in `<head>`
- [ ] Fonts don't block text rendering (`font-display: swap`)
- [ ] LCP element in initial HTML (not JS-rendered)
- [ ] Speculation Rules added for likely-next navigations

---

## INP: Interaction to Next Paint

INP measures responsiveness across ALL interactions (clicks, taps, key presses). Reports worst interaction at 98th percentile.

**Total INP = Input Delay + Processing Time + Presentation Delay**

| Phase | Target |
|-------|--------|
| Input delay | < 50ms |
| Processing | < 100ms |
| Presentation | < 50ms |

### Common INP issues

**Long tasks blocking main thread**
```javascript
// ❌ Long synchronous task
function processLargeArray(items) {
  items.forEach(item => expensiveOperation(item));
}

// ✅ Break into chunks and yield
async function processLargeArray(items) {
  const CHUNK_SIZE = 100;
  for (let i = 0; i < items.length; i += CHUNK_SIZE) {
    items.slice(i, i + CHUNK_SIZE).forEach(expensiveOperation);
    if ('scheduler' in window && 'yield' in scheduler) {
      await scheduler.yield(); // continuation resumes at boosted priority
    } else {
      await new Promise(r => setTimeout(r, 0)); // fallback: loses priority
    }
  }
}
```

**Heavy event handlers**
```javascript
// ✅ Prioritize visual feedback, yield, then do heavy work
button.addEventListener('click', async () => {
  button.classList.add('loading'); // immediate visual feedback
  if ('scheduler' in window && 'yield' in scheduler) {
    await scheduler.yield(); // let browser paint loading state
  }
  const result = calculateComplexThing();
  updateUI(result);
  if ('requestIdleCallback' in window) {
    requestIdleCallback(() => trackEvent('click')); // lowest priority last
  }
});
```

**Third-party scripts**
```javascript
// ❌ Eagerly loaded
<script src="https://heavy-widget.com/widget.js"></script>

// ✅ Lazy loaded on interaction
button.addEventListener('click', () => {
  import('https://heavy-widget.com/widget.js').then(w => w.init());
}, { once: true });
```

**Excessive React re-renders**
```javascript
// ✅ Memoize expensive components
const MemoizedExpensive = React.memo(ExpensiveComponent);

// ✅ Use useTransition for non-urgent updates
const [isPending, startTransition] = useTransition();
startTransition(() => setExpensiveState(newValue));
```

### INP debugging
```javascript
new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (entry.duration > 200) {
      console.warn('Slow interaction:', {
        type: entry.name,
        duration: entry.duration,
        target: entry.target
      });
    }
  }
}).observe({ type: 'event', buffered: true, durationThreshold: 40 });
```

For real-user field data, use the `web-vitals/attribution` build — `onINP()` from it attaches Long Animation Frame (LoAF) breakdowns identifying the longest script.

### INP checklist
- [ ] No tasks > 50ms on main thread
- [ ] Event handlers complete quickly (< 100ms)
- [ ] Visual feedback provided immediately
- [ ] Heavy work deferred with `requestIdleCallback` or `scheduler.yield()`
- [ ] Third-party scripts don't block interactions
- [ ] Input handlers debounced where appropriate
- [ ] Web Workers for CPU-intensive operations

---

## CLS: Cumulative Layout Shift

CLS measures unexpected shifts. Formula: `impact fraction × distance fraction`.

### Common CLS causes

**Images without dimensions**
```html
<!-- ❌ Causes layout shift when loaded -->
<img src="photo.jpg" alt="Photo">

<!-- ✅ Space reserved -->
<img src="photo.jpg" alt="Photo" width="800" height="600">
<!-- or -->
<img src="photo.jpg" alt="Photo" style="aspect-ratio: 4/3; width: 100%;">
```

**Ads and embeds without reserved space**
```html
<!-- ✅ Reserve space for ads -->
<div style="min-height: 250px;">
  <iframe src="https://ad-network.com/ad" height="250"></iframe>
</div>

<!-- ✅ Aspect-ratio container for video -->
<div style="aspect-ratio: 16/9;">
  <iframe src="https://youtube.com/embed/..." style="width: 100%; height: 100%;"></iframe>
</div>
```

**Web fonts causing FOUT**
```css
/* ✅ Match fallback font metrics to reduce shift */
@font-face {
  font-family: 'Custom';
  src: url('custom.woff2') format('woff2');
  font-display: swap;
  size-adjust: 105%;
  ascent-override: 95%;
  descent-override: 20%;
}
```

**Animations triggering layout**
```css
/* ❌ Animates layout properties */
.animate { transition: height 0.3s, width 0.3s; }

/* ✅ Use transform instead */
.animate { transition: transform 0.3s; }
.animate.expanded { transform: scale(1.2); }
```

**Dynamically injected content above the viewport**
```javascript
// ❌ Inserts content above viewport
notifications.prepend(newNotification);

// ✅ Insert below viewport, or animate in with transform
newNotification.style.transform = 'translateY(-100%)';
notifications.prepend(newNotification);
requestAnimationFrame(() => { newNotification.style.transform = ''; });
```

### CLS debugging
```javascript
new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (!entry.hadRecentInput) {
      console.log('Layout shift:', entry.value);
      entry.sources?.forEach(source => {
        console.log('  Shifted element:', source.node);
        console.log('  Previous rect:', source.previousRect);
        console.log('  Current rect:', source.currentRect);
      });
    }
  }
}).observe({ type: 'layout-shift', buffered: true });
```

### CLS checklist
- [ ] All images have `width`/`height` or `aspect-ratio`
- [ ] All videos/embeds have reserved space
- [ ] Ads have `min-height` containers
- [ ] Fonts use `font-display: optional` or matched fallback metrics
- [ ] Dynamic content inserted below viewport
- [ ] Animations use `transform`/`opacity` only
- [ ] No content injected above existing content

---

## Measurement

**Lab testing:** Chrome DevTools Performance panel → Lighthouse, WebPageTest, `npx lighthouse <url>`

**Field data (real users):**
```javascript
import { onLCP, onINP, onCLS } from 'web-vitals';

function sendToAnalytics({ name, value, rating }) {
  gtag('event', name, {
    event_category: 'Web Vitals',
    value: Math.round(name === 'CLS' ? value * 1000 : value),
    event_label: rating
  });
}

onLCP(sendToAnalytics);
onINP(sendToAnalytics);
onCLS(sendToAnalytics);
```

Also check: Chrome User Experience Report (CrUX), Google Search Console Core Web Vitals report.

## Framework quick reference

### Next.js
```jsx
// LCP
import Image from 'next/image';
<Image src="/hero.jpg" priority fill alt="Hero" />

// INP
const HeavyComponent = dynamic(() => import('./Heavy'), { ssr: false });
```

### React
```jsx
// LCP
<link rel="preload" href="/hero.jpg" as="image" fetchpriority="high" />

// INP
const [isPending, startTransition] = useTransition();
startTransition(() => setExpensiveState(newValue));

// CLS — always specify dimensions in img tags
```
