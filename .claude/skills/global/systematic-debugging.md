# Systematic Debugging

## Overview

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## When to Use

Use for ANY technical issue: test failures, bugs, unexpected behavior, performance problems, build failures, integration issues.

**Use this ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes and they didn't work

**Don't skip when:**
- Issue seems simple (simple bugs have root causes too)
- You're in a hurry (systematic is faster than thrashing)

## The Four Phases

Complete each phase before proceeding to the next.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read Error Messages Carefully**
   - Don't skip past errors or warnings — they often contain the exact solution
   - Read stack traces completely; note line numbers, file paths, error codes

2. **Reproduce Consistently**
   - Can you trigger it reliably? What are the exact steps?
   - If not reproducible → gather more data, don't guess

3. **Check Recent Changes**
   - What changed that could cause this? Git diff, recent commits, new dependencies, config changes.

4. **Gather Evidence in Multi-Component Systems**

   When the system has multiple components (API → service → database, CI → build → signing):

   **Add diagnostic instrumentation BEFORE proposing fixes:**
   ```bash
   # Layer 1: Log what data enters each component
   echo "=== Env vars entering build: ==="
   env | grep IDENTITY || echo "IDENTITY not in environment"

   # Layer 2: Log what exits
   echo "=== Keychain state: ==="
   security list-keychains
   ```

   Run once to gather evidence showing WHERE it breaks. Then investigate that specific layer.

5. **Trace Data Flow**

   When the error is deep in the call stack:
   - Where does the bad value originate?
   - What called this with the bad value?
   - Trace upward until you find the source
   - Fix at source, not at symptom

### Phase 2: Pattern Analysis

1. **Find Working Examples** — locate similar working code in the same codebase
2. **Compare Against References** — if implementing a pattern, read the reference completely, every line
3. **Identify Differences** — list everything different between working and broken, however small
4. **Understand Dependencies** — what config, environment, or assumptions does this rely on?

### Phase 3: Hypothesis and Testing

1. **Form Single Hypothesis** — "I think X is the root cause because Y." Be specific.
2. **Test Minimally** — the SMALLEST possible change to test the hypothesis. One variable at a time.
3. **Verify Before Continuing** — Did it work? Yes → Phase 4. No → form a NEW hypothesis. Do NOT add more fixes on top.
4. **When You Don't Know** — Say "I don't understand X." Don't pretend.

### Phase 4: Implementation

1. **Create Failing Test Case** — simplest possible reproduction. Automated test if possible. Use the `test-driven-development` skill.
2. **Implement Single Fix** — address the root cause. ONE change. No "while I'm here" improvements.
3. **Verify Fix** — test passes? No other tests broken? Issue actually resolved? Use the `verification-before-completion` skill.
4. **If Fix Doesn't Work** — STOP. Count how many fixes you've tried.
   - If < 3: Return to Phase 1 with new information
   - **If ≥ 3: STOP and question the architecture (step 5)**

5. **If 3+ Fixes Failed: Question Architecture**

   Pattern indicating an architectural problem:
   - Each fix reveals new shared state, coupling, or problem in a different place
   - Fixes require massive refactoring to implement
   - Each fix creates new symptoms elsewhere

   **Stop. Discuss with Amanda before attempting more fixes.**

   This is not a failed hypothesis — this is a wrong architecture.

## Red Flags — STOP and Follow Process

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "One more fix attempt" (when already tried 2+)
- Each fix reveals a new problem in a different place

**ALL of these mean: STOP. Return to Phase 1.**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "I'll write test after confirming fix" | Untested fixes don't stick. Test first proves it. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "I see the problem, let me fix it" | Seeing symptoms ≠ understanding root cause. |
| "One more fix attempt" (after 2+) | 3+ failures = architectural problem. Question pattern, don't fix again. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence | Understand WHAT and WHY |
| **2. Pattern** | Find working examples, compare | Identify differences |
| **3. Hypothesis** | Form theory, test minimally | Confirmed or new hypothesis |
| **4. Implementation** | Create test, fix, verify | Bug resolved, tests pass |

## When Process Reveals "No Root Cause"

If systematic investigation reveals an environmental, timing-dependent, or external issue:

1. Document what you investigated
2. Implement appropriate handling (retry, timeout, error message)
3. Add logging for future investigation

**But:** 95% of "no root cause" cases are incomplete investigation.

## Real-World Impact

- Systematic approach: 15–30 minutes to fix
- Random fixes approach: 2–3 hours of thrashing
- First-time fix rate: 95% vs 40%
- New bugs introduced: near zero vs common
