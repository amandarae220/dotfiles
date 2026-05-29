# Commit Review Skill

## Trigger
Run this on every staged diff before committing.

## Input
- Staged diff only (`git diff --staged`)
- Do NOT pull full file context unless a score is critically ambiguous

## Output Format
```
SUMMARY: [one sentence — what changed and why]

SCORES:
  Code Quality    : [1-10] — [one-line callout]
  Test Coverage   : [1-10] — [one-line callout]
  Accessibility   : [1-10] — [one-line callout or N/A]
  Security        : [1-10] — [one-line callout]
  Performance     : [1-10] — [one-line callout]
  Design System   : [1-10] — [one-line callout or N/A]

READINESS: [READY / NEEDS WORK / BLOCKED]

BLOCKERS: [bullet list only if BLOCKED or NEEDS WORK]
```

## Scoring Rubric

### Code Quality
- 10: Clean, named well, no duplication, single responsibility
- 7–9: Minor issues, nothing structural
- 4–6: Complexity creep, unclear naming, or duplication
- 1–3: Hard to read, deeply nested, or multiple concerns mixed

### Test Coverage
- 10: Tests added/updated alongside every changed behavior
- 7–9: Partial coverage, happy path covered
- 4–6: Tests exist but don't cover the change
- 1–3: No tests for changed behavior
- N/A: Config, assets, or type-only changes

### Accessibility
- 10: Semantic HTML, aria where needed, keyboard nav works, contrast passes
- 7–9: Minor gaps, nothing blocking
- 4–6: Missing aria labels, focus issues, or untested interactions
- 1–3: Non-semantic markup, no keyboard support, or contrast failures
- N/A: Non-UI changes

### Security
- 10: No secrets, inputs validated, no unsafe operations
- 7–9: Minor concerns, nothing exploitable
- 4–6: Unvalidated inputs or risky patterns worth flagging
- 1–3: Exposed secrets, unsafe innerHTML, or auth bypasses

### Performance
- 10: No unnecessary renders, optimized imports, no bundle bloat
- 7–9: Minor inefficiencies, acceptable tradeoffs
- 4–6: Unoptimized loops, large imports, or missing memoization
- 1–3: Significant render thrashing or bundle impact

### Design System
- 10: All values from tokens, no one-off components
- 7–9: Mostly compliant, minor raw values
- 4–6: Mix of tokens and raw values
- 1–3: Ignores design system entirely
- N/A: Non-UI changes

## Readiness Thresholds
- READY: All scores ≥ 7, no blockers
- NEEDS WORK: Any score 4–6
- BLOCKED: Any score ≤ 3 or any security/a11y critical issue
