---
name: project-orchestrate
description: Set up a persistent, git-tracked `.tasks/` project plan from a `brief.md` or a direct project request, OR extend an existing `.tasks/` project by appending new phases. Use when Codex needs to start a new multi-phase software project, create phase/task files for future sessions, initialize project tracking, convert a rough brief into structured execution state, or add a phase to a project (with or without an `extension.md`).
---

# Project Orchestrate

Create the initial `.tasks/` workspace for a project that will be executed over multiple sessions, or extend an existing one with new phases. Treat `.tasks/` as the source of truth for project state.

## Routing

First action: check whether `.tasks/project.md` exists.

- **Absent** → run the **Bootstrap** flow (Steps 1–6 below).
- **Present** → run the **Extension** flow (Steps E1–E5 in "Extending a Project").

## Workflow

### Step 1: Gather project inputs

Look for `brief.md` in the project root. If it exists, read it first.

If there is no `brief.md`, gather the missing information from the user request or infer the minimum viable structure:
- project title
- overall goal
- major phases
- key constraints

If the user has not asked for repository creation or remote setup, do not assume GitHub operations are wanted. This Codex version focuses on local project scaffolding first.

Supported `brief.md` shape:

```yaml
title: My App
goal: |
  What the project builds and why.
repo: private
phases:
  - name: Foundation
    goal: Set up database, auth, and core models
  - name: API Layer
    goal: REST endpoints for all resources
```

### Step 2: Create `.tasks/` structure

Create:
- `.tasks/project.md`
- `.tasks/phase-N/phase.md` for each phase
- task files only for Phase 1

Do not generate task files for future phases yet. Leave future phases as stubs so they can be refined using what is learned in earlier phases.

### Step 3: Write `project.md`

Use this structure:

```yaml
---
title: <project title>
status: in-progress
current-phase: 1
repo: <public|private|unknown>
github: ~
created: <YYYY-MM-DD>
---
## Goal
<project goal>

## Phases
- [ ] Phase 1: Foundation
- [ ] Phase 2: API Layer
```

If the repository visibility or GitHub URL is unknown, use `unknown` or `~` rather than inventing values.

### Step 4: Write each `phase.md`

Use this structure:

```yaml
---
phase: <N>
title: <phase title>
status: <open for phase 1, pending otherwise>
opened: <YYYY-MM-DD for phase 1, ~ otherwise>
closed: ~
---
## Goal
<what this phase accomplishes>

## Exit Criteria
- <criterion 1>
- <criterion 2>

## Tasks
- [ ] task-01-<name>.md
- [ ] task-02-<name>.md
```

Keep exit criteria concrete enough that a later executor can decide whether the phase is ready to close.

### Step 5: Generate Phase 1 task files

Generate individual task files only for Phase 1 with this structure:

```yaml
---
id: task-<NN>
title: <task title>
status: pending
complexity: <low|medium|high>
blocked-by: ~
---
## Goal
<what this task must accomplish>

## Context
<relevant background and files>

## Acceptance Criteria
- [ ] <criterion 1>
- [ ] <criterion 2>

## Notes
```

Complexity guidance:
- `low`: straightforward, well-bounded work
- `medium`: multiple files or moderate judgment required
- `high`: cross-cutting, ambiguous, or implementation-heavy work

### Step 6: Hand off cleanly

After scaffolding:
- summarize the phases created
- state how many Phase 1 tasks were generated
- tell the next agent or session to use `$phase-execute`

## Extending a Project

Use this flow when `.tasks/project.md` already exists and the user wants to append new phases — either after the project was marked `done` or mid-stream while a phase is still open. Closed phases are never modified.

`extension.md` uses the same `phases:` shape as `brief.md`. It does not re-declare `title` or `repo` — those already live in `project.md`.

```yaml
---
phases:
  - name: UI Polish
    goal: Address feedback from user testing on dashboard
    exit-criteria: |
      - All flagged dashboard issues resolved
  - name: Performance pass
    goal: Reduce dashboard p95 load to <500ms
---
## Notes
Free-form context the assistant should read before generating tasks.
```

### Step E1: Detect extension mode

Read `.tasks/project.md`. Capture from frontmatter: `title`, `status`, `current-phase`. From `## Phases`, capture each entry and its checkbox state.

### Step E2: Load existing phase state

Glob `.tasks/phase-*/phase.md`. Parse each frontmatter (`phase`, `title`, `status`, `opened`, `closed`). Compute the highest existing phase number `K` from the `phase:` field — do not rely on folder lexical sort, since `phase-10` would sort before `phase-2`. Note whether any phase has `status: open`.

### Step E3: Gather new phases

Look for `extension.md` in the repo root. If present, read its `phases:` list and any `## Notes` section.

If absent, ask the user:
- What new work needs to happen?
- How would you split it into phases (if more than one)?
- Any exit criteria for each?

### Step E4: Append phases

For each new phase, numbering from `K+1`:

- Append `- [ ] Phase N: <title>` to `## Phases` in `.tasks/project.md`.
- Create `.tasks/phase-N/phase.md` with `status: pending`, `opened: ~`, `closed: ~`, the goal, exit criteria, and an empty Tasks list. Do not pre-generate task files — `$phase-execute` generates them when it opens the phase.
- Update `.tasks/project.md` frontmatter:
  - If `status: done`, flip to `status: in-progress`.
  - Set `current-phase` to the lowest phase number with `status: open` or `status: pending`. If a phase is already open, leave `current-phase` on it; otherwise it becomes `K+1`.
- Do not modify any closed phase's files or `closed:` date. Do not modify task files inside closed phases.

### Step E5: Commit and hand off

- If `extension.md` was used, delete it so a later run does not reapply it and `$project-status` does not keep flagging it.
- Commit: `chore(tasks): extend with N phase(s) — <comma-separated titles>`.
- Do not push automatically. This Codex port keeps the same local-first stance as the bootstrap flow: only push or perform GitHub operations when the user explicitly asks.
- Tell the user: "Added Phase K+1..K+N. Start a new session and invoke `$phase-execute` to begin."

## Edge Cases

- **Mid-stream extension while a phase is open** — append after the open phase. Don't touch the open phase or its tasks. `current-phase` stays on the open phase.
- **`extension.md` exists but `.tasks/` doesn't** — stop and tell the user: "Found extension.md but no .tasks/ project. Did you mean brief.md?" Do not auto-rename or proceed.
- **Project status was `done`** — flip to `in-progress`. Leave closed phases' `closed:` dates intact and untouched.
- **User wants tasks pre-filled in the new phase** — out of scope here. Tasks are deferred to `$phase-execute`. The user can edit `phase-N/phase.md` directly if they want explicit task control.

## Rules

- Keep `.tasks/` as the single source of truth.
- Never backfill fake status, dates, or GitHub metadata.
- Never generate future-phase task files during initialization.
- Prefer concrete tasks and acceptance criteria over broad placeholders.
- If the request is too vague to produce useful phases, stop and ask for the missing project goal rather than inventing it.
