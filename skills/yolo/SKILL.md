---
name: yolo
description: Use when user wants to commit and push changes without confirmation prompts or pull requests. Triggers on "yolo", "commit and push", "just push it", "submit my changes", "push to origin", "git submit", "save and push", or any request to stage+commit+push in one shot without being asked questions.
---

# Yolo — Auto Git Submit

Commit everything and push to origin. No confirmation. No PR. Just ship it.

## Steps

1. **Check status** — `git status` + `git diff --stat` to see what changed
2. **Stage all** — `git add -A`
3. **Read the diff** — `git diff --cached` to understand what's being committed
4. **Write commit message** — concise, imperative mood, max 72 chars subject line. Describe *what* changed; add a body line only if the *why* isn't obvious. Always append the co-author line.
5. **Commit** — use a heredoc to avoid quoting issues:
   ```bash
   git commit -m "$(cat <<'EOF'
   your subject line here

   Optional body if needed.

   Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
   EOF
   )"
   ```
6. **Push** — `git push origin $(git branch --show-current)`
   - If the remote branch doesn't exist yet: `git push -u origin $(git branch --show-current)`

## Rules

- **Never ask for confirmation** — the user said yolo, they mean it
- **Never create a PR** — push and stop
- **Never use --no-verify** unless the user explicitly says to skip hooks
- If the working tree is clean, say so and stop — no empty commits
- If a pre-commit hook fails, report the error and stop — don't retry blindly or force-push
- If `git push` is rejected (non-fast-forward), report it and stop — don't rebase or reset without asking
