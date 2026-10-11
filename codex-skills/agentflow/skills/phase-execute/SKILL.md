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

Generating tasks is context-heavy (read `project.md`, the spec, and the prior phase's outcomes, then write N files). Every numbered item in the phase's `## Carry from phase <N-1>` section must become (or be folded into) a task that names it; `## Open follow-ups` items become tasks only when they fall inside the phase goal. If the user has enabled delegation, push this into a one-shot planner subagent that writes the task files and returns only a one-line summary — no explanation, no preamble — so the main thread stays lean for the execution loop. Otherwise generate them in-thread, but keep only the resulting files in mind, not the full breakdown reasoning.

Generate tasks for the phase goal as written. Do not widen the phase's scope or add tasks for work a later phase owns.

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

When you do delegate, keep spawn counts low and deterministic: one agent per task is the shape. Do not delegate work you could finish in a handful of tool calls, do not use several agents where one suffices, and never spawn an agent purely to double-check your own work.

### Step 4: Execute pending tasks

For each task with `status: pending`:
- respect `blocked-by`
- read the full task file
- execute it using the `$task-implement` workflow

If multiple tasks are unblocked and the user explicitly wants delegation, parallelize only the tasks with disjoint ownership.

### Step 5: Review task outcomes

A `done` status is a claim, not proof — verify it, don't rubber-stamp it. **One review pass per task, then move on.** After each task:
- reread the task file fresh, not the summary
- confirm the status is now `done` or `blocked`
- confirm each acceptance criterion is genuinely met; a checked box is an assertion, so spot-check that `## Notes` describe real work and that tests back the behavior
- if the task warranted tests and none were written, treat the done as suspect — TDD was skipped; redo it or record the concern
- inspect `## Notes` for follow-up risks or unresolved questions
- when reporting findings to yourself or the user, report everything you see at every severity and filter afterwards; do not pre-screen for "only the important issues"

**If delegation is enabled, review with a separate agent that did not write the code**, handing it the task file and the diff. A fresh reviewer is a real gate; the same thread re-reading its own work is much weaker, and repeating that self-check adds cost without adding confidence. In serial in-thread mode this split is unavailable, so make the single pass count rather than looping over it.

If a task is blocked, record that in the phase-level reasoning but continue with other independent tasks when possible.

### Step 6: Close the phase

When all tasks are `done` or `blocked`:
- if the exit criteria need a full test-suite or build run, run it but keep only a compact verdict (PASS, or FAIL + failing-test names) — never retain full logs or stack traces in the thread; if delegation is enabled, run it in a verifier subagent that returns just that verdict
- write the carry-forward into the next phase's `phase.md` (skip for the final phase): a `## Carry from phase N` section (numbered process/tooling fixes the next phase must make, each becomes a task when it is planned) and a `## Open follow-ups from phase N` section (recheck-later items, decisions waiting on the user, things not to touch). Source them from task `## Notes`, recorded Minor findings and blocked reasons; write "none" rather than omitting a heading. If the next phase does not exist yet, put both under `## Carry-forward` in this phase's `phase.md`
- update `phase.md` to `status: closed`
- set `closed: <YYYY-MM-DD>`
- update `.tasks/project.md` to check off the phase
- advance `current-phase` if another phase remains

If the final phase is closed, set project status to `done`.

### Step 7: Hand off

Lead with the outcome, then the detail. Return a concise summary:
- which phase ran
- counts of done and blocked tasks
- whether the next phase is ready
- where to inspect blocked task notes if any remain

## Communicating During the Loop

The loop is long and mostly mechanical, so narrate it thinly:

- **One sentence before starting**, naming the phase and task count.
- **One line per task transition** — started / done / blocked / redoing. Nothing more unless you change direction (reordering tasks, reopening work, hitting a systemic problem), in which case say why in one line.
- **Do not echo a task's full result into your prose.** The task file and the commit log already hold it.
- **Lead with the outcome at phase close** — done/blocked counts first, supporting detail after.

Files you write get the same discipline: `phase.md` and `project.md` edits are bookkeeping, not prose. Match their length to what the next session needs to read.

## Rules

- Never modify closed phases unless the user explicitly asks.
- A done status is a claim until the task file backs it; verify it, never rubber-stamp.
- Treat `.tasks/` as the source of truth, not the conversation.
- Prefer serial execution unless the user explicitly requests parallel delegation.
- Keep delegation deterministic and low: one agent per task, never several where one works, never one just to re-check your own output.
- Review once per task; prefer a fresh reviewer over re-reading your own work, and never soften severity to avoid a fix loop.
- Do not assume subagent tools or model-routing features are available.
- Generate tasks for a newly opened phase only when needed.
- Keep the thread lean: task generation and full-suite/build runs are context-heavy — delegate them to a subagent when delegation is enabled, and never retain full test/build logs (keep only pass/fail + failing names).
