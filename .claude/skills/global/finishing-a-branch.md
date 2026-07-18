# Finishing a Development Branch

## Overview

Guide completion of development work: verify → score the diff → stage → hand off.

**Core principle:** Clean diff + passing tests, then Amanda takes it from there.

## Step 1: Verify Tests

Run the project's test suite (`npm test` / `pytest` / `go test ./...` / etc.).

If tests fail: show failures, **STOP**. Fix before proceeding.

## Step 2: Score the Diff

Run the `commit-review` skill on `git diff`.

- **BLOCKED** or **NEEDS WORK** → fix issues before continuing.
- **READY** → continue to Step 3.

## Step 3: Stage Changes

Stage only the files changed for this feature — never use `git add .` or `git add -A`:

```bash
git add path/to/file1 path/to/file2 ...
```

Then show a summary:

```
Ready for your review:

Staged files:
  - path/to/file1 — [one-line description of what changed]
  - path/to/file2 — [one-line description of what changed]

Diff score: READY (N/10)
Tests: passing

Run `git diff --staged` to review before committing.
```

**Stop here.** Amanda writes the commit message and creates the PR.

## Step 4: Discard (if requested)

If Amanda asks to discard the work, confirm first:

```
This will permanently delete:
- Branch <name>
- All uncommitted changes

Type 'discard' to confirm.
```

Wait for exact confirmation. Then:

```bash
git branch -D <feature-branch>
```

## Never

- Run `git commit` — not even when asked
- Run `git push` — not even when asked
- Create a PR or draft PR
- Use `git add .` or `git add -A` — stage specific files only
- Add Co-Authored-By or any Claude attribution
- Proceed with failing tests
- Proceed with a BLOCKED or NEEDS WORK diff score
- Delete work without typed `discard` confirmation

## Always

- Verify tests before scoring
- Score the diff (commit-review) before staging
- Stage specific files, never the whole working tree
- Show a plain summary of what's staged and stop
