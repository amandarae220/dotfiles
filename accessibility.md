# Accessibility Skill

## Standard
WCAG 2.1 AA minimum on all UI. No exceptions.

## Always Enforce

### Semantic HTML
- Use correct elements: `<button>` for actions, `<a>` for navigation, `<nav>`, `<main>`, `<section>`, `<header>`, `<footer>`
- Never use `<div>` or `<span>` as interactive elements without role + keyboard support

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

### Color & Contrast
- Text: 4.5:1 minimum contrast ratio
- Large text (18px+ or 14px+ bold): 3:1 minimum
- UI components and focus indicators: 3:1 minimum
- Never use color as the only means of conveying information

### Images & Media
- All `<img>` tags have meaningful `alt` text or `alt=""` if decorative
- Videos have captions
- No content flashes more than 3 times per second

### Forms
- Every input has an associated `<label>` (not placeholder as label)
- Error messages are programmatically associated with their input
- Required fields indicated in label, not just color

## Callout Format
When flagging an a11y issue in a review:
`A11Y [severity: low|medium|critical]: [element] — [issue] — [fix]`

## Critical = BLOCKED
Any critical a11y issue blocks the commit. No exceptions.
