---
name: task-implement
description: Use when a subagent has been dispatched to implement a specific task in a .tasks/ project workflow. Triggers when given a task file path, or when a single in-progress task file exists in the current phase folder.
---

# Task Implement

Executes a single task from a `.tasks/phase-N/task-NN-name.md` file. Handles the full lifecycle: load → in-progress → implement → verify → done/blocked. Called by subagents dispatched from `phase-execute`.

## When to Use

- Dispatched as a subagent by `phase-execute` with a task file path
- Directly invoked to implement a specific task
- Auto-detect mode: one `in-progress` task exists in the current phase

## Process

```dot
digraph implement {
    "Load task file" [shape=box];
    "Set status: in-progress + commit" [shape=box];
    "Write test first" [shape=box];
    "Implement" [shape=box];
    "Blocked?" [shape=diamond];
    "Run verification" [shape=box];
    "Criteria met?" [shape=diamond];
    "Fill Notes + set done + commit" [shape=box];
    "Fill Notes + set blocked + commit" [shape=box];
    "Return DONE" [shape=doublecircle];
    "Return BLOCKED" [shape=doublecircle];

    "Load task file" -> "Set status: in-progress + commit";
    "Set status: in-progress + commit" -> "Write test first";
    "Write test first" -> "Implement";
    "Implement" -> "Blocked?";
    "Blocked?" -> "Run verification" [label="no"];
    "Blocked?" -> "Fill Notes + set blocked + commit" [label="yes"];
    "Run verification" -> "Criteria met?";
    "Criteria met?" -> "Fill Notes + set done + commit" [label="yes"];
    "Criteria met?" -> "Implement" [label="no, iterate"];
    "Fill Notes + set done + commit" -> "Return DONE";
    "Fill Notes + set blocked + commit" -> "Return BLOCKED";
}
```

### Step 1 — Load Task

Read the task file. If no path was given, scan the current phase folder for the single `in-progress` task.

Understand:
- `## Goal` — what must be accomplished
- `## Context` — background, relevant files
- `## Acceptance Criteria` — what done looks like

### Step 2 — Set In-Progress

Update task file frontmatter: `status: in-progress`

Commit: `chore(task-NN): start — <title>`

### Step 3 — Implement with TDD

Write tests before implementation:
- Write a failing test that captures the desired behavior, then run it to confirm it fails for the right reason.
- Write the minimal code to make it pass, then run the tests again.
- Refactor once green. Commit at meaningful checkpoints.

If you hit unexpected failures, debug systematically — reproduce the failure, form one hypothesis at a time, and confirm the root cause before changing code. Don't guess-and-check.

If you realize the task is blocked (missing dependency, ambiguous requirement, external blocker):
- Stop immediately — do not guess or work around
- Document the reason clearly in `## Notes`
- Set `status: blocked`
- Commit: `chore(task-NN): blocked — <title>`
- Return `BLOCKED`

### Step 4 — Verify

Before marking done, verify against reality — run the relevant tests, checks, or commands and confirm the actual output rather than assuming. Evidence before claims.

Check each acceptance criterion in the task file:
- Update `- [ ]` to `- [x]` for each criterion met
- If a criterion cannot be met, treat as blocked

### Step 5 — Fill Notes & Close

Update the `## Notes` section with:
- What was done
- Files created or modified (with paths)
- Key decisions made and why
- Any concerns or follow-up items

Update frontmatter: `status: done`

Commit: `chore(task-NN): done — <title>`

### Step 6 — Return Status

Return one of these to the calling executor:

| Status | When |
|--------|------|
| `DONE` | All acceptance criteria met, no concerns |
| `DONE_WITH_CONCERNS` | Done but with issues noted in Notes (tech debt, assumptions, risks) |
| `BLOCKED` | Could not complete — reason in Notes |

## Key Rules

- **Never skip TDD** — tests before implementation, always
- **Never guess past a blocker** — document and return BLOCKED
- **Notes are required** — the executor and future agents depend on them
- **Commit every state change** — in-progress, done, blocked
- **Read the task file fresh** — don't rely on the prompt summary; the file is the spec
