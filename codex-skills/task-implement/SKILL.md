---
name: task-implement
description: Complete one tracked task from a `.tasks/phase-N/task-NN-name.md` workflow. Use when Codex is given a task file path, asked to continue an in-progress tracked task, or needs to execute a single task end to end with status updates, verification, and implementation notes.
---

# Task Implement

Execute a single task file from load through completion or blockage. The task file is the spec.

## Workflow

### Step 1: Load the task file

Read the task file first. If no path is given, look for a single `in-progress` task in the current phase.

Understand:
- `## Goal`
- `## Context`
- `## Acceptance Criteria`
- `blocked-by`

If the task depends on unfinished work, do not start implementation. Mark or keep it blocked and document why.

### Step 2: Mark work in progress

If the task is not already `in-progress`, update the frontmatter to:

```yaml
status: in-progress
```

Do this before implementing so later sessions can reconstruct state accurately.

### Step 3: Implement with TDD

Inspect the relevant code before editing, then drive the work test-first.

**The iron law: no production code without a failing test first.** If you write implementation before its test, delete it and restart from the test — don't keep it "as reference" and backfill a test that passes on the first run.

Follow red-green-refactor:
1. **Red** — write one minimal test for a single behavior. Run it and watch it fail *for the right reason* (feature missing, not a typo or import error). A test that passes immediately proves nothing.
2. **Green** — write the simplest code that makes it pass. No extra options, config, or abstraction the test doesn't demand.
3. **Refactor** — clean up while staying green, then write the next failing test.

Use real code over mocks unless a dependency makes mocks unavoidable. If a test is hard to write, the design is usually the problem — simplify the interface rather than the test.

Don't rationalize past this: "too simple to test", "I'll add tests after", "I already tested it manually", and "deleting this code is wasteful" all mean the same thing — write the test first.

If you discover a real blocker such as a missing dependency, conflicting requirement, missing credential, or ambiguous spec:
- stop implementation
- explain the blocker in `## Notes`
- set `status: blocked`

Do not guess past blockers.

### Step 4: Verify against acceptance criteria

Before marking the task done:
- run the relevant tests, checks, or manual verification steps
- update each satisfied acceptance criterion from `- [ ]` to `- [x]`
- leave unmet criteria unchecked

If any required criterion cannot be met, do not mark the task done.

### Step 5: Fill notes and close

Update `## Notes` with:
- what changed
- files created or modified
- key decisions
- residual risks or follow-up work

Then set one of:
- `status: done` when all criteria are met
- `status: blocked` when the task cannot proceed cleanly

### Step 6: Return status

Return one of:
- `DONE`
- `DONE_WITH_CONCERNS`
- `BLOCKED`

Use `DONE_WITH_CONCERNS` only when the acceptance criteria are met but meaningful risks or deferred work remain and are documented in `## Notes`.

## Rules

- Never skip TDD; write the failing test before the implementation.
- Read the task file fresh; do not rely on prompt summaries.
- Keep status transitions accurate.
- Never mark criteria complete without verification.
- Never hide blockers inside a vague note.
- Notes are required because future sessions depend on them.
