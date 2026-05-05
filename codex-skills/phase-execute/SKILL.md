---
name: phase-execute
description: Execute one open phase from a `.tasks/` project workflow. Use when Codex needs to continue a tracked project, open the next pending phase, generate tasks for a newly opened phase, supervise or perform task execution, and close the phase when its tasks are complete or blocked.
---

# Phase Execute

Run a single project phase using the current `.tasks/` state. Read the files fresh each time; do not rely on prior session memory.

## Workflow

### Step 1: Locate the active phase

Scan `.tasks/` for a `phase.md` with `status: open`.

If none exists, find the lowest-numbered `status: pending` phase and open it. When opening a pending phase:
- update `status: open`
- set `opened: <YYYY-MM-DD>`
- generate task files if the phase does not have any yet

Always read `.tasks/project.md` before continuing.

### Step 2: Load phase context

Read the active `phase.md` and identify:
- phase goal
- exit criteria
- task checklist
- task dependencies via `blocked-by`

Then read each relevant task file instead of trusting only the checklist.

### Step 3: Choose an execution mode

Default to serial execution in the current agent.

Only delegate tasks to subagents if:
- the user explicitly wants delegation or parallel agent work, and
- the tasks are independent enough to avoid stepping on each other

If subagents are not clearly appropriate, implement tasks one at a time in the current thread and use `$task-implement` as the operating procedure.

### Step 4: Execute pending tasks

For each task with `status: pending`:
- respect `blocked-by`
- read the full task file
- execute it using the `$task-implement` workflow

If multiple tasks are unblocked and the user explicitly wants delegation, parallelize only the tasks with disjoint ownership.

### Step 5: Review task outcomes

After each task:
- reread the task file
- confirm the status is now `done` or `blocked`
- confirm acceptance criteria were updated honestly
- inspect `## Notes` for follow-up risks or unresolved questions

If a task is blocked, record that in the phase-level reasoning but continue with other independent tasks when possible.

### Step 6: Close the phase

When all tasks are `done` or `blocked`:
- update `phase.md` to `status: closed`
- set `closed: <YYYY-MM-DD>`
- update `.tasks/project.md` to check off the phase
- advance `current-phase` if another phase remains

If the final phase is closed, set project status to `done`.

### Step 7: Hand off

Return a concise summary:
- which phase ran
- counts of done and blocked tasks
- whether the next phase is ready
- where to inspect blocked task notes if any remain

## Rules

- Never modify closed phases unless the user explicitly asks.
- Treat `.tasks/` as the source of truth, not the conversation.
- Prefer serial execution unless the user explicitly requests parallel delegation.
- Do not assume subagent tools or model-routing features are available.
- Generate tasks for a newly opened phase only when needed.
