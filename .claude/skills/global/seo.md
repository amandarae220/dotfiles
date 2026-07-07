# SEO

Technical and on-page search engine optimization.

Use when asked to "improve SEO", "optimize for search", "fix meta tags", "add structured data", "sitemap", or "search engine optimization."

## Technical SEO

### Crawlability

**robots.txt:**
```text
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/
Disallow: /private/

# Don't block resources needed for rendering (CSS, JS, images)

Sitemap: https://example.com/sitemap.xml
```

**Per-page meta robots:**
```html
<!-- Default: indexable -->
<meta name="robots" content="index, follow">

<!-- Noindex specific pages -->
<meta name="robots" content="noindex, nofollow">

<!-- Control snippet length -->
<meta name="robots" content="max-snippet:150, max-image-preview:large">
```

**Canonical URLs — prevent duplicate content:**
```html
<link rel="canonical" href="https://example.com/current-page">
```

### XML sitemap

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://example.com/</loc>
    <lastmod>2024-01-15</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
```

- Max 50,000 URLs or 50MB per sitemap; use a sitemap index for larger sites
- Include only canonical, indexable URLs
- Update `lastmod` when content changes
- Submit to Google Search Console

### URL structure

```
✅ https://example.com/products/blue-widget
✅ https://example.com/blog/how-to-use-widgets

❌ https://example.com/p?id=12345
❌ https://example.com/products/item/category/subcategory/blue-widget-2024
```

- Hyphens not underscores; lowercase only; < 75 chars
- HTTPS always
- Avoid unnecessary parameters

---

## On-page SEO

### Title tags

```html
<!-- ✅ Keyword near front, brand at end, 50–60 chars -->
<title>Blue Widgets for Sale | Premium Quality | Example Store</title>
```

### Meta descriptions

```html
<!-- ✅ 150–160 chars, unique per page, compelling CTA -->
<meta name="description" content="Shop premium blue widgets with free shipping. 30-day returns. Rated 4.9/5. Save 20% today.">
```

### Heading structure

```html
<!-- ✅ Single h1, logical hierarchy, no skipped levels -->
<h1>Blue Widgets — Premium Quality</h1>
  <h2>Product Features</h2>
    <h3>Durability</h3>
  <h2>Customer Reviews</h2>
```

### Image SEO

```html
<img src="blue-widget-product-photo.webp"
     alt="Blue widget with chrome finish, side view showing control panel"
     width="800" height="600"
     loading="lazy">
```

- Descriptive filename with keywords
- Alt text describes what's in the image
- WebP/AVIF with fallbacks; lazy load below-fold

### Internal linking

```html
<!-- ❌ -->
<a href="/products">Click here</a>

<!-- ✅ Descriptive anchor text -->
<a href="/products/blue-widgets">Browse our blue widget collection</a>
```

---

## Structured data (JSON-LD)

### Article

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "How to Choose the Right Widget",
  "description": "Complete guide to selecting widgets.",
  "image": "https://example.com/article-image.jpg",
  "author": {
    "@type": "Person",
    "name": "Jane Smith",
    "url": "https://example.com/authors/jane-smith"
  },
  "publisher": {
    "@type": "Organization",
    "name": "Example Blog",
    "logo": { "@type": "ImageObject", "url": "https://example.com/logo.png" }
  },
  "datePublished": "2024-01-15",
  "dateModified": "2024-01-20"
}
</script>
```

### Product

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Blue Widget Pro",
  "image": "https://example.com/blue-widget.jpg",
  "description": "Premium blue widget.",
  "brand": { "@type": "Brand", "name": "WidgetCo" },
  "offers": {
    "@type": "Offer",
    "price": "49.99",
    "priceCurrency": "USD",
    "availability": "https://schema.org/InStock"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.8",
    "reviewCount": "1250"
  }
}
</script>
```

### FAQ

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What colors are available?",
      "acceptedAnswer": { "@type": "Answer", "text": "Blue, red, and green." }
    }
  ]
}
</script>
```

### Breadcrumbs

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    { "@type": "ListItem", "position": 1, "name": "Home", "item": "https://example.com" },
    { "@type": "ListItem", "position": 2, "name": "Products", "item": "https://example.com/products" },
    { "@type": "ListItem", "position": 3, "name": "Blue Widgets", "item": "https://example.com/products/blue-widgets" }
  ]
}
</script>
```

Validate at: [Google Rich Results Test](https://search.google.com/test/rich-results) or [Schema.org Validator](https://validator.schema.org/).

---

## AI search visibility

AI search engines (ChatGPT search, Perplexity, Gemini) cite pages from retrieval pipelines, not ranked results. Low-cost things that don't hurt:

- **Don't block AI crawlers wholesale.** `OAI-SearchBot`, `PerplexityBot`, `ClaudeBot`, `Google-Extended` each have separate `robots.txt` user-agents. Decide per-bot.
- **Schema.org structured data.** AI summarizers parse it more reliably than prose layouts.
- **Self-contained first paragraphs.** AI summaries pull short, coherent passages. A direct answer in the first 1–2 sentences is more extractable than buried content.

`llms.txt` (an index of your site's pages in Markdown, at `/llms.txt`) is unproven — no major AI vendor has confirmed they read it as of mid-2026. Fine as a 5-minute speculative add for content sites; not a ranking factor.

---

## Hreflang (multi-language sites)

```html
<link rel="alternate" hreflang="en" href="https://example.com/page">
<link rel="alternate" hreflang="es" href="https://example.com/es/page">
<link rel="alternate" hreflang="x-default" href="https://example.com/page">
```

```html
<html lang="en">
```

---

## SEO audit checklist

### Critical
- [ ] HTTPS enabled
- [ ] robots.txt allows crawling
- [ ] No `noindex` on important pages
- [ ] Title tags present and unique
- [ ] Single `<h1>` per page

### High priority
- [ ] Meta descriptions present
- [ ] Sitemap submitted to Search Console
- [ ] Canonical URLs set
- [ ] Mobile-responsive (`width=device-width`)
- [ ] Core Web Vitals passing (see `core-web-vitals.md`)

### Medium priority
- [ ] Structured data implemented
- [ ] Internal linking with descriptive anchor text
- [ ] Image alt text
- [ ] Descriptive URLs
- [ ] Breadcrumb navigation

### Ongoing
- [ ] Fix crawl errors in Search Console
- [ ] Update sitemap when content changes
- [ ] Monitor ranking changes
- [ ] Check for broken links

## Tools

| Tool | Use |
|------|-----|
| Google Search Console | Monitor indexing, fix issues |
| Google PageSpeed Insights | Performance + Core Web Vitals |
| Rich Results Test | Validate structured data |
| Lighthouse | Full SEO audit |
