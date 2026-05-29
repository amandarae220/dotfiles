# Decision Log Template Skill

## When to Use
Any time an architectural, tooling, or significant pattern decision is made.
One file per decision. Stored in `/docs/decisions/` in the project repo.

## Filename Format
`YYYY-MM-DD-short-decision-title.md`
Example: `2025-05-28-state-management-approach.md`

## Template

```markdown
# [Decision Title]

**Date**: YYYY-MM-DD
**Status**: [Proposed | Accepted | Deprecated | Superseded by YYYY-MM-DD-other-decision.md]
**Decider(s)**: [Name or role]

## Context
[What situation or problem forced this decision? What constraints existed?]

## Options Considered

### Option 1: [Name]
- Pros: 
- Cons: 

### Option 2: [Name]
- Pros: 
- Cons: 

### Option 3: [Name] (if applicable)
- Pros: 
- Cons: 

## Decision
[What was chosen and the one-sentence reason why.]

## Consequences
- [What gets easier]
- [What gets harder]
- [What we're accepting as a known tradeoff]

## Revisit If
[Specific condition that would warrant reconsidering this decision.]
```

## Rules
- Write it at decision time, not after — context fades fast
- "Context" explains the constraints, not just the symptoms
- "Consequences" must include at least one thing that gets harder — no decision is free
- "Revisit If" must be specific — "if it becomes a problem" is not acceptable
