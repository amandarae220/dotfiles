# Finishing a Development Branch

## Overview

Guide completion of development work: verify → score the diff → present options → execute choice.

**Core principle:** Clean diff + passing tests before any merge or PR.

## Step 1: Verify Tests

Run the project's test suite (`npm test` / `pytest` / `go test ./...` / etc.).

If tests fail: show failures, **STOP**. Fix before proceeding.

## Step 2: Score the Diff

Run the `commit-review` skill on `git diff <base-branch>...HEAD`.

- **BLOCKED** or **NEEDS WORK** → fix issues before continuing.
- **READY** → continue to Step 3.

## Step 3: Determine Base Branch

```bash
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Confirm with Amanda if unclear.

## Step 4: Present Options

```
Implementation complete. Tests pass. Diff is READY. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

## Step 5: Execute Choice

### Option 1: Merge Locally

```bash
git checkout <base-branch>
git pull
git merge <feature-branch>
```

Re-run tests on merged result. If passing, delete branch:

```bash
git branch -d <feature-branch>
```

### Option 2: Push and Create PR

```bash
git push -u origin <feature-branch>
```

Use the `pr-template` skill to write the PR description. Do NOT delete branch — it stays alive for PR iteration.

### Option 3: Keep As-Is

Report: "Keeping branch `<name>` at current state." No action taken.

### Option 4: Discard

Confirm first:
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>

Type 'discard' to confirm.
```

Wait for exact confirmation. Then:

```bash
git branch -D <feature-branch>
```

## Red Flags

**Never:**
- Commit or push without an explicit request — always show what would be committed and wait
- Proceed with failing tests
- Proceed with a BLOCKED or NEEDS WORK diff score
- Merge without re-running tests on the merged result
- Delete work without typed `discard` confirmation
- Force-push without explicit request

**Always:**
- Verify tests before scoring
- Score the diff (commit-review) before presenting options
- Get typed confirmation before discarding
