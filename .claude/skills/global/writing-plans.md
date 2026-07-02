# Writing Plans

Use when you have a spec or requirements for a multi-step task, before touching code.

## Overview

Write comprehensive implementation plans. Document which files to touch for each task, include real code, exact test commands with expected output, and commit steps. Give the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Scope Check

If the spec covers multiple independent subsystems, suggest splitting into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each is responsible for.

- Each file has one clear responsibility
- Files that change together should live together
- Prefer smaller, focused files over large ones that do too much
- In existing codebases, follow established patterns

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle. Fold setup, configuration, and scaffolding into the task that needs them. Split only where a reviewer could meaningfully reject one task while approving its neighbor. Each task ends with an independently testable deliverable.

## Bite-Sized Step Granularity

Each step is one action (2–5 minutes):
- "Write the failing test" — step
- "Run it to verify it fails" — step
- "Write minimal implementation" — step
- "Run tests, verify they pass" — step
- "Commit" — step

## Plan Document Header

Every plan MUST start with:

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence]

**Architecture:** [2–3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

## Global Constraints

[Project-wide requirements — version floors, dependency limits, naming rules, platform requirements — one line each with exact values. Every task implicitly includes this section.]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.ts`
- Modify: `exact/path/to/existing.ts:123-145`
- Test: `tests/exact/path/to/test.ts`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter and return types]

- [ ] **Step 1: Write the failing test**

```typescript
test('specific behavior', () => {
  const result = fn(input);
  expect(result).toBe(expected);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `npm test path/to/test.ts`
Expected: FAIL with "fn not defined"

- [ ] **Step 3: Write minimal implementation**

```typescript
function fn(input: string): string {
  return expected;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `npm test path/to/test.ts`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.ts src/path/file.ts
git commit -m "feat: add specific feature"
```
````

## No Placeholders

Every step must contain what an engineer actually needs. These are plan failures — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "handle edge cases" (show the code)
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — tasks may be read out of order)
- Steps that describe what to do without showing how

## Remember

- Exact file paths always
- Complete code in every step
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

## Self-Review

After writing the complete plan:

1. **Spec coverage:** Can you point to a task that implements every requirement? List gaps.
2. **Placeholder scan:** Search for TBD, TODO, vague steps. Fix them.
3. **Type consistency:** Do method names and signatures used in later tasks match what was defined in earlier tasks?

Fix issues inline. If a spec requirement has no task, add one.

## Handoff

After saving the plan:

> "Plan complete and saved to `docs/plans/<filename>.md`. Ready to start implementation — work through tasks top to bottom, committing after each one passes."
