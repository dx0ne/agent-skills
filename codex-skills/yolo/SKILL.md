---
name: yolo
description: Stage, commit, and push the current branch in one pass without extra confirmation prompts. Use when the user explicitly wants a fast git submit flow such as "yolo", "commit and push", "just push it", or similar instructions to stage all changes, create one commit, and push to origin.
---

# Yolo

Perform a single git submit flow: inspect, stage, commit, and push. Move fast, but do not skip basic safety checks.

## Workflow

### Step 1: Inspect the worktree

Run:
- `git status`
- `git diff --stat`

If the working tree is clean, report that and stop.

### Step 2: Stage everything

Stage the current worktree with:

```bash
git add -A
```

### Step 3: Read the staged diff

Inspect the staged changes before writing the commit message:

```bash
git diff --cached
```

Use the actual diff to decide what the commit is about.

### Step 4: Write the commit message

Use a concise imperative subject line under 72 characters. Add a body only when the reason is not obvious from the diff.

Do not add Claude-specific co-author lines.

### Step 5: Commit and push

Create the commit, then push the current branch to `origin`.

If the remote branch does not exist yet, set upstream while pushing.

## Rules

- Never ask for an extra confirmation after the user explicitly invoked `yolo`.
- Never create a pull request as part of this skill.
- Never use `--no-verify` unless the user explicitly asks.
- If commit hooks fail, stop and report the failure.
- If push is rejected, stop and report it; do not rebase, reset, or force-push without explicit instruction.
