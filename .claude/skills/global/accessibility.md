# Accessibility Skill

## Standard
WCAG 2.1 AA minimum on all UI. No exceptions.

## Always Enforce

### Semantic HTML
- Use correct elements: `<button>` for actions, `<a>` for navigation, `<nav>`, `<main>`, `<section>`, `<header>`, `<footer>`
- Never use `<div>` or `<span>` as interactive elements without role + keyboard support

### Headings
- Section titles must be real heading elements (`<h2>`, `<h3>`), not styled `<p>` or `<div>`. Visual sameness is not enough — AT users navigate by heading
- Never skip levels (h1 → h3 is a violation). Each section descends one level
- One `<h1>` per page. If `<noscript>` or fallback content contains one, it counts as a duplicate

### Keyboard Navigation
- All interactive elements reachable and operable via keyboard
- Visible focus indicators on all focusable elements — never `outline: none` without a replacement
- Logical tab order — matches visual reading order
- Modal/dialog traps focus and restores it on close

### ARIA
- Only add ARIA when semantic HTML isn't sufficient
- Every icon-only button needs `aria-label`
- Dynamic content updates use `aria-live` regions where appropriate
- Never use `aria-hidden="true"` on focusable elements
- `title` attribute is NOT announced by most screen readers. Use `aria-label` for accessible names on non-text elements (heatmap cells, status dots, etc.)
- For tooltips with definitions: pair the trigger button with an `aria-describedby` pointing to a `.sr-only` span containing the full text. The visible tooltip is a sighted-user convenience; AT users get the content through the describedby relationship
- For focusable containers with interactive children (cards with buttons inside): set an explicit `aria-label` on the container with a summary. Without it, AT walks every child and reads the same content twice — once when the container is focused, once when each child is focused

### Color & Contrast
- Text: 4.5:1 minimum contrast ratio (1.4.3)
- Large text (18px+ or 14px+ bold): 3:1 minimum
- UI components and focus indicators: 3:1 minimum (1.4.11)
- Never use color as the only means of conveying information

**Safe values on light backgrounds (#fafafa–#ffffff):**
- Text: `#6c6c6c` (~5:1). Avoid `#888`, `#999`, `#ccc` for any text
- UI components / icons: `#767676` clears 3:1; `#aaa` and lighter don't
- A vivid brand color that looks fine at hero sizes often FAILS 4.5:1 at small label sizes. Maintain a darker "text-safe" variant of each brand color for small-text use (e.g., `--brand-accent: #7657f4` for badges; `--tag-text-purple: #6042e3` for the same hue as text)

### Text Size
- Minimum body text size: 11px. WAVE flags 10px and below as "very small text"
- Applies to ALL visible text including small caps, labels, badge contents, asterisks
- For circular badges: if you bump the text size, bump the container proportionally. A 14×14 badge won't comfortably hold 11px text — go to 18×18

### Touch Targets
- WCAG 2.5.8 (AA in WCAG 2.2): 24×24 minimum
- For small icons where increasing visible size disrupts layout, extend the hit area with a pseudo-element:
  ```css
  .icon-btn { position: relative; }
  .icon-btn::before { content: ''; position: absolute; inset: -6px; }
  ```
  A 13×13 icon becomes a 25×25 click target without affecting surrounding flex/grid layout

### Images & Media
- All `<img>` tags have meaningful `alt` text or `alt=""` if decorative
- Videos have captions
- No content flashes more than 3 times per second

### Forms
- Every input has an associated `<label>` (not placeholder as label)
- Error messages are programmatically associated with their input
- Required fields indicated in label, not just color
- **Gotcha:** info buttons and `.sr-only` description spans inside a `<label>` leak into the input's accessible name. Screen readers will read the definition twice — once when the input is focused, once when the info button is focused. Fix: wrap the label TEXT in a `<span id="lbl-x">`, then put `aria-labelledby="lbl-x"` on the input. The button + description stay visually inside the label but no longer pollute the input's name

### JavaScript Fallback
- Avoid `<noscript>`. WAVE flags it as an alert regardless of content, and AT may read it even when JS is enabled
- Replace with the no-js class pattern:
  ```html
  <html class="no-js">
  <head>
    <script>document.documentElement.classList.remove('no-js')</script>
    <style>
      .no-js-message { display: none; }
      html.no-js .no-js-message { display: block; }
      html.no-js #app { display: none; }
    </style>
  </head>
  ```
  Identical UX, no scanner noise, no `<h1>` duplication risk

## Testing
Code review catches ~60% of a11y issues. The rest needs:
- **axe DevTools** Chrome extension — automated rule scan
- **WAVE** (wave.webaim.org) — visual overlay; surfaces contrast + small-text issues that axe misses
- **VoiceOver** (Cmd+F5 on Mac) — verify announcements one element at a time. Watch for duplicate announcements when a focusable container holds focusable children
- **Keyboard-only pass** — unplug the mouse, tab through everything, escape closes modals

## Callout Format
When flagging an a11y issue in a review:
`A11Y [severity: low|medium|critical]: [element] — [issue] — [fix]`

## Critical = BLOCKED
Any critical a11y issue blocks the commit. No exceptions.
