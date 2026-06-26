---
name: phase-execute
description: Use when starting a new session to execute a project phase. Triggers on "execute phase", "start phase", "run phase", "continue project", or when a project has a .tasks/ folder with an open or pending phase ready to work on.
---

# Phase Execute

Supervises execution of a single project phase. Finds the current open phase, dispatches a subagent per task (each invoking `task-implement`), monitors results, and closes the phase when done. The executor never implements — it only supervises.

**The executor's context is a scarce resource.** It runs a long, many-turn loop (one dispatch + one or more review rounds per task), and every turn re-reads the whole resident context from cache. So the executor must keep that context lean: it never does heavy reasoning itself (task generation), never reads large outputs into its own context (full test logs, build output, big diffs), and never implements. All of that is pushed into short-lived subagents that return compact summaries. Bloat in the executor multiplies across every remaining turn of the loop.

## When to Use

- Starting a new session to work on a project with a `.tasks/` folder
- A phase was just opened by `project-orchestrate` or a prior phase just closed
- Resuming a phase that was partially completed

## Process

```dot
digraph execute {
    "Find open phase" [shape=diamond];
    "Open next pending phase" [shape=box];
    "Dispatch planner subagent → tasks" [shape=box];
    "Read phase.md" [shape=box];
    "Pending tasks remain?" [shape=diamond];
    "Dispatch implementer → task-implement" [shape=box];
    "Returned BLOCKED?" [shape=diamond];
    "Log blocked reason" [shape=box];
    "Dispatch reviewer subagent on diff" [shape=box];
    "Reviewer approved?" [shape=diamond];
    "Dispatch fix subagent → task-implement" [shape=box];
    "Mark task done" [shape=box];
    "All tasks done/blocked?" [shape=diamond];
    "Close phase + update project.md" [shape=box];
    "Final phase?" [shape=diamond];
    "Mark project done" [shape=box];
    "Instruct: next session" [shape=doublecircle];

    "Find open phase" -> "Read phase.md" [label="found"];
    "Find open phase" -> "Open next pending phase" [label="none open"];
    "Open next pending phase" -> "Dispatch planner subagent → tasks";
    "Dispatch planner subagent → tasks" -> "Read phase.md";
    "Read phase.md" -> "Pending tasks remain?";
    "Pending tasks remain?" -> "Dispatch implementer → task-implement" [label="yes"];
    "Pending tasks remain?" -> "All tasks done/blocked?" [label="no"];
    "Dispatch implementer → task-implement" -> "Returned BLOCKED?";
    "Returned BLOCKED?" -> "Log blocked reason" [label="yes"];
    "Returned BLOCKED?" -> "Dispatch reviewer subagent on diff" [label="no"];
    "Dispatch reviewer subagent on diff" -> "Reviewer approved?";
    "Reviewer approved?" -> "Mark task done" [label="yes"];
    "Reviewer approved?" -> "Dispatch fix subagent → task-implement" [label="no"];
    "Dispatch fix subagent → task-implement" -> "Dispatch reviewer subagent on diff";
    "Mark task done" -> "Pending tasks remain?";
    "Log blocked reason" -> "Pending tasks remain?";
    "All tasks done/blocked?" -> "Close phase + update project.md" [label="yes"];
    "Close phase + update project.md" -> "Final phase?" ;
    "Final phase?" -> "Mark project done" [label="yes"];
    "Final phase?" -> "Instruct: next session" [label="no"];
    "Mark project done" -> "Instruct: next session";
}
```

### Step 1 — Find the Current Phase

Scan `.tasks/` for a `phase.md` with `status: open`. If none found, find the next `status: pending` phase (lowest phase number) and set it `status: open`, `opened: <date>`.

If the phase already has task files, skip to Step 2 — do **not** regenerate them.

**If the phase has no task files yet, do not generate them inline.** Task generation is heavy reasoning (read `project.md`, read the spec, read the prior phase's outcomes, design the breakdown, write N files) and it would sit in the executor's context for the entire supervision loop. Push it into a one-shot **planner subagent** instead. The executor reads only the planner's one-line summary, not its reasoning.

Dispatch the planner, then re-read the now-populated `phase.md` (Step 2). Commit: `chore(phase-N): open — N tasks generated`.

**Planner subagent prompt template:**
```
You are planning one phase of an agentic project workflow. Generate the task files; do not implement anything.

Project file: <absolute path to .tasks/project.md>
Phase file:   <absolute path to .tasks/phase-N/phase.md>
Spec:         <absolute path to the spec under .tasks/specs/ that produced this phase, from project.md's ## Specs log>

Read project.md, the phase.md goal + exit criteria, and the spec. Also read the ## Notes of the most recent CLOSED phase's task files — later phases must build on what earlier phases actually learned.

Write one task file per unit of work into .tasks/phase-N/, named task-NN-<name>.md, using this exact format:
---
id: task-<NN>
title: <task title>
status: pending
complexity: <low|medium|high>
blocked-by: ~        # task-NN of any task this depends on, or ~
---
## Goal
## Context
## Acceptance Criteria
- [ ] <criterion>
## Notes

Then update phase.md's ## Tasks checklist to list the files you created. Keep tasks small and independently testable; set blocked-by honestly so the executor can order them.

Return ONE line only: "Generated M tasks for phase N: task-01-x, task-02-y, ...". Do not return your reasoning.
```

### Step 2 — Read Phase Context

Read `phase.md` to load:
- Phase goal
- Exit criteria
- Task list (checked items = done, unchecked = pending/in-progress)

Read `.tasks/project.md` for overall project context.

### Step 3 — Dispatch Tasks

For each task file with `status: pending`, dispatch a subagent:

**Model selection by complexity:**
| complexity | model |
|-----------|-------|
| low | claude-haiku-4-5-20251001 |
| medium | claude-sonnet-4-6 |
| high | claude-opus-4-6 |

**Subagent prompt template:**
```
You are implementing a task in an agentic project workflow.

Project: <project title>
Phase <N>: <phase title>
Goal: <phase goal>

Task file: <absolute path to task-NN-name.md>

Invoke the `task-implement` skill to execute this task. Read the task file first to understand what's needed.

Implement test-first, as `task-implement` requires. Your returned status will be checked against the task file — the acceptance criteria and the tests backing them.

When complete, return one of:
- DONE — task complete, acceptance criteria met
- DONE_WITH_CONCERNS — done but with issues noted in task Notes
- BLOCKED — could not complete, reason documented in task Notes
```

**Run tasks sequentially by default.** Only parallelize if tasks have no dependencies on each other (check `blocked-by` fields).

**Record the base commit** (`git rev-parse HEAD`) before dispatching each implementer — the Step 4 review diff is the range from that commit to `HEAD` after the task.

### Step 4 — Review Gate

The executor never accepts a returned DONE on its own. It dispatches an **independent reviewer subagent** — separate from the implementer, fresh context — and gates task completion on the reviewer's verdict.

1. **Triage the return.** Read the task file fresh. If the implementer returned `BLOCKED`, ensure the reason is in `## Notes`, commit `chore(task-NN): blocked — <title>`, and continue to the next task — no review needed. Otherwise confirm `status` was updated and the work was committed, then review.

2. **Build the diff.** Capture the task's commits as the range from the base commit recorded in Step 3 to current `HEAD`. The reviewer sees the diff, not the implementer's self-report.

3. **Dispatch the reviewer subagent** with the template below. It gets the task file (its acceptance criteria are the spec) and the diff.

   **Reviewer model — use a smaller/cheaper model than the implementer.** Review is mostly judgment over a bounded diff, so scale down:
   | diff | model |
   |------|-------|
   | small, mechanical | claude-haiku-4-5-20251001 |
   | multi-file or subtle logic | claude-sonnet-4-6 |

   Don't default the reviewer to the implementer's model — that silently doubles cost for no gain.

4. **Gate on the verdict:**
   - **APPROVED** (spec ✅, no Critical/Important issues): mark the task done, commit `chore(task-NN): done — <title>`, continue.
   - **CHANGES_REQUESTED:** dispatch a fix subagent — re-invoke `task-implement` on the same task file, handing it the reviewer's findings — then rebuild the diff and re-dispatch the reviewer. Loop until APPROVED. Never advance with open Critical/Important findings.
   - Record Minor findings in the task's `## Notes` for later; they don't block.

**Reviewer subagent prompt template:**
```
You are reviewing one task's implementation in an agentic project workflow. You did not write this code — review it independently.

Project: <project title>
Phase <N>: <phase title>

Task file: <absolute path to task-NN-name.md>
Diff to review: <commit range or diff file path>

The task file's ## Acceptance Criteria are the spec. Review ONLY the diff against them.

Report:
- Spec: ✅ if every acceptance criterion is met and nothing beyond the task was built; ❌ with specifics otherwise.
- Quality: issues as Critical / Important / Minor. Flag missing or fake tests — the task required test-first development, so behavior must be backed by real tests that would fail without the change.
- Verdict: APPROVED (spec ✅, no Critical/Important) or CHANGES_REQUESTED with the findings list.

Do not implement fixes. Do not soften or pre-rate severity to avoid a fix loop. Report exactly what you find.
```

### Step 5 — Close Phase

When all tasks are `done` or `blocked`:

0. **Verify exit criteria without running anything in the executor's context.** If `phase.md`'s exit criteria require a full-suite run, a build, or any command with bulky output, **dispatch a one-shot verifier subagent** — never run it in the supervisor session, where the output would bloat every remaining turn. The verifier runs the suite/build and returns only a compact verdict: `PASS`, or `FAIL` + the names of failing tests/checks (no full logs). If it returns FAIL, reopen the offending work as a fix task rather than closing the phase.

   **Verifier subagent prompt template:**
   ```
   You are verifying a phase's exit criteria. Run the checks; do not fix anything.

   Phase file: <absolute path to .tasks/phase-N/phase.md>
   Run the commands needed to confirm the ## Exit Criteria (test suite, build, lint as applicable).
   Return ONE compact verdict: "PASS", or "FAIL: <failing test/check names>". Do NOT paste full logs or stack traces.
   ```

1. Update `phase.md`: `status: closed`, `closed: <date>`
2. Update `project.md` task checklist for this phase: `- [x] Phase N: <title>`
3. Increment `current-phase` in `project.md`
4. Commit: `chore(phase-N): closed`
5. Push

If this was the final phase: set `project.md` `status: done`, commit, push.

### Step 6 — Hand Off

Output to the human:

> Phase N complete. X tasks done, Y blocked.
> [If blocked tasks]: Review `.tasks/phase-N/` for blocked task details.
> Start a new session and invoke `phase-execute` for Phase N+1.

Or if project is done:
> Project complete. All phases closed. See `.tasks/project.md` for summary.

## Key Rules

- **Executor never implements** — all implementation work goes to subagents
- **Executor never generates tasks inline** — task generation is a one-shot planner subagent (Step 1); the executor reads only its one-line summary, never its reasoning
- **Executor never runs the suite or build in its own context** — exit-criteria checks go to a verifier subagent that returns a compact PASS/FAIL (Step 5); full logs never enter the supervisor session
- **Keep the executor's context lean** — it runs a many-turn loop and pays cache-read on its whole context every turn; push heavy reading/reasoning into subagents that return summaries
- **Review is an independent gate** — a separate, cheaper reviewer subagent (never the implementer, never the executor reading checkmarks) must approve each task before it closes; loop fixes until approved
- **Phases are the archive boundary** — never read or modify closed phases
- **Source of truth is `.tasks/`** — always read current file state, don't rely on memory
- **Commit every state change** — phase open, task done/blocked, phase close
- **Sequential by default** — only parallelize tasks with no `blocked-by` dependencies
