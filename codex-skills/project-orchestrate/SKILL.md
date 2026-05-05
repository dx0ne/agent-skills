---
name: project-orchestrate
description: Set up a persistent, git-tracked `.tasks/` project plan from a `brief.md` or a direct project request. Use when Codex needs to start a new multi-phase software project, create phase/task files for future sessions, initialize project tracking, or convert a rough brief into structured execution state.
---

# Project Orchestrate

Create the initial `.tasks/` workspace for a project that will be executed over multiple sessions. Treat `.tasks/` as the source of truth for project state.

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

## Rules

- Keep `.tasks/` as the single source of truth.
- Never backfill fake status, dates, or GitHub metadata.
- Never generate future-phase task files during initialization.
- Prefer concrete tasks and acceptance criteria over broad placeholders.
- If the request is too vague to produce useful phases, stop and ask for the missing project goal rather than inventing it.
