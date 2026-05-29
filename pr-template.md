# PR Template Skill

## When to Use
Generate this for every PR description. Pull from commit history and diff.

## Template

```markdown
## What
[One sentence. What does this PR do?]

## Why
[One to two sentences. What problem does it solve or what value does it add?]

## Changes
- [Specific change 1]
- [Specific change 2]
- [Specific change 3]

## Testing
- [ ] Unit tests added/updated
- [ ] Tested in browser manually
- [ ] Edge cases handled: [list them]
- [ ] Accessibility verified

## Screenshots
[If UI changes — before/after. If no UI changes, remove this section.]

## Notes for Reviewer
[Anything that needs context, explains a non-obvious decision, or flags a known tradeoff.]
```

## Rules
- "What" is never just "fixes bug" or "adds feature" — be specific
- "Why" answers the business or user need, not the technical how
- Every checkbox must be honestly checked — no aspirational ticks
- If there are no tests, say why — don't just leave the box unchecked
- Notes for Reviewer should preempt questions, not create them
