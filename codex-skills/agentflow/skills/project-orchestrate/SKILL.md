---
name: project-orchestrate
description: Set up a persistent, git-tracked `.tasks/` project plan from a dated spec in `.tasks/specs/` or a direct project request, OR extend an existing `.tasks/` project by appending new phases. Use when Codex needs to start a new multi-phase software project, create phase/task files for future sessions, initialize project tracking, convert a rough brief into structured execution state, or add a phase to a project.
---

# Project Orchestrate

Create the initial `.tasks/` workspace for a project that will be executed over multiple sessions, or extend an existing one with new phases. Treat `.tasks/` as the source of truth for project state.

Input is a **dated spec** in `.tasks/specs/`, written by `$project-specify` (or by hand). Each spec is an immutable `YYYY-MM-DD-<slug>.md` file with a `kind:` frontmatter field. `$project-orchestrate` selects one spec, builds phases from it, and records consumption in `project.md`'s `## Specs` log.

## Routing

First action: check whether `.tasks/project.md` exists.

- **Absent** → run the **Bootstrap** flow (Steps 1–6 below). Expect `kind: bootstrap` spec.
- **Present** → run the **Extension** flow (Steps E1–E5 in "Extending a Project"). Expect `kind: extension` spec.

A `kind` that disagrees with the inferred mode is an error — stop and report it (see Edge Cases).

## Spec Selection

Both flows begin by selecting exactly one spec from `.tasks/specs/`. Selection rules are identical for bootstrap and extension; only the expected `kind` differs.

1. **Explicit path wins.** If the caller named a spec (e.g. "orchestrate `.tasks/specs/2026-06-17-auth.md`"), use that file.
2. **Else newest unconsumed spec.** Glob `.tasks/specs/*.md`. A spec is *consumed* if its path appears in `project.md`'s `## Specs` log (on bootstrap there is no `project.md`, so every spec is unconsumed). Among unconsumed specs, pick the one with the newest `YYYY-MM-DD` filename prefix.
   - Exactly one unconsumed spec → use it.
   - Several unconsumed specs → list them and ask the user which to consume. Do not guess.
   - Zero unconsumed specs → fall back to the deprecated root file (`brief.md` for bootstrap, `extension.md` for extend); see "Deprecated fallbacks".
3. **Validate `kind` against mode.** Read the selected spec's frontmatter `kind`. Bootstrap mode expects `kind: bootstrap`; Extend mode expects `kind: extension`. A mismatch is an error — stop and report it, do not auto-fix.

Specs are **immutable history**: never edit or delete a spec after consuming it. Consumption is recorded only in `project.md`'s `## Specs` log.

### Spec file formats

**Bootstrap spec** (`kind: bootstrap`):
```yaml
---
kind: bootstrap
title: My App
repo: private            # public | private
date: 2026-06-17
goal: |
  What the project builds and why.
phases:
  - name: Foundation
    goal: Set up database, auth, and core models
  - name: API Layer
    goal: REST endpoints for all resources
---
## Design
<approaches considered, the decision, rationale>
```

**Extension spec** (`kind: extension`) — `title`/`repo` already live in `project.md`:
```yaml
---
kind: extension
date: 2026-07-02
phases:
  - name: UI Polish
    goal: Address feedback from user testing
    exit-criteria: |
      - All flagged issues resolved
---
## Notes
<free-form context to read before generating tasks>
```

The structured frontmatter fields drive `$project-orchestrate`; the prose sections (`## Design`, `## Notes`) make the file double as the reviewable spec.

### Deprecated fallbacks

If `.tasks/specs/` has no usable unconsumed spec, fall back to a fixed-name root file, treated as **deprecated** (kept for backward compatibility only):

- Bootstrap → root `brief.md` (same fields as the bootstrap spec frontmatter, without `kind`).
- Extend → root `extension.md` (same `phases:` / `## Notes` shape as the extension spec).

Prefer dated specs. When a fallback file is used, note in the hand-off that the project should migrate to `.tasks/specs/`. A deprecated root `extension.md` fallback *may* be deleted after use, since it has no dated identity and would otherwise be re-detected; prefer migrating it into `.tasks/specs/` instead.

## Bootstrap Flow

### Step 1: Select & read the bootstrap spec

Run **Spec Selection** above, expecting `kind: bootstrap`. Read the selected spec's frontmatter and `## Design` section.

Capture `title`, `goal`, `repo` (`public` or `private`), and the `phases:` list. If `repo:` is missing or unknown, use `unknown` rather than inventing a value. If no spec and no `brief.md` fallback exist, gather the missing information from the user:
- What is the project goal?
- What are the major phases? (e.g., Foundation → API → Frontend → Deploy)
- Any constraints (tech stack, deadlines, dependencies)?

Remember the selected spec's path — it is logged in Step 5.

If the user has not asked for repository creation or remote setup, do not assume GitHub operations are wanted. This Codex version focuses on local project scaffolding first.

### Step 2: Create `.tasks/` structure

`.tasks/specs/` already exists (the spec lives there) — never clobber it.

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

## Specs
```

The `## Specs` provenance log starts empty and is filled in Step 5. If the repository visibility or GitHub URL is unknown, use `unknown` or `~` rather than inventing values.

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

### Step 6: Log the spec & hand off

Append the consumed spec to `project.md`'s `## Specs` log, recording path (relative to `.tasks/`), kind, and the phase range it produced:

```markdown
## Specs
- specs/2026-06-17-auth-system.md (bootstrap) → phases 1-3
```

If a deprecated `brief.md` fallback was used, record it as `brief.md (bootstrap) → phases 1-N`.

Commit: `chore(tasks): init project — N phases, M tasks`

Do not push automatically. Only push or perform GitHub operations when the user explicitly asks.

After committing, summarize:
- the phases created
- how many Phase 1 tasks were generated
- tell the next agent or session to use `$phase-execute`

## Extending a Project

Use this flow when `.tasks/project.md` already exists and the user wants to append new phases — either after the project was marked `done` or mid-stream while a phase is still open. Closed phases are never modified.

### Step E1: Detect extension mode

Read `.tasks/project.md`. Its presence means Extend mode (expect `kind: extension`). Capture from frontmatter: `title`, `status`, `current-phase`. From `## Phases`, capture each entry and its checkbox state. Read the existing `## Specs` log so you know which specs are already consumed.

### Step E2: Load existing phase state

Glob `.tasks/phase-*/phase.md`. Parse each frontmatter (`phase`, `title`, `status`, `opened`, `closed`). Compute the highest existing phase number `K` from the `phase:` field — do not rely on folder lexical sort, since `phase-10` would sort before `phase-2`. Note whether any phase has `status: open`.

### Step E3: Select the extension spec

Run **Spec Selection** above, expecting `kind: extension`. Read the selected spec's `phases:` list and any `## Notes` section.

If no unconsumed spec and no `extension.md` fallback exist, ask the user:
- What new work needs to happen?
- How would you split it into phases (if more than one)?
- Any exit criteria for each?

Remember the selected spec's path — it is logged in Step E5.

### Step E4: Append phases

For each new phase, numbering from `K+1`:

- Append `- [ ] Phase N: <title>` to `## Phases` in `.tasks/project.md`.
- Create `.tasks/phase-N/phase.md` with `status: pending`, `opened: ~`, `closed: ~`, the goal, exit criteria, and an empty Tasks list. Do not pre-generate task files — `$phase-execute` generates them when it opens the phase.
- For phase `K+1` only: if `phase-K/phase.md` has a `## Carry-forward` section (written by `$phase-execute` when it closed the last phase with no successor), copy its two subsections into the new `phase.md` as `## Carry from phase K` and `## Open follow-ups from phase K`, then replace the `## Carry-forward` body in `phase-K/phase.md` with a one-line pointer to the new phase.
- Update `.tasks/project.md` frontmatter:
  - If `status: done`, flip to `status: in-progress`.
  - Set `current-phase` to the lowest phase number with `status: open` or `status: pending`. If a phase is already open, leave `current-phase` on it; otherwise it becomes `K+1`.
- Do not modify any closed phase's files or `closed:` date. Do not modify task files inside closed phases.

### Step E5: Log the spec, commit, and hand off

- Append the consumed extension spec to `project.md`'s `## Specs` log:
  ```markdown
  - specs/2026-07-02-billing.md (extension) → phases 4-5
  ```
  If a deprecated `extension.md` fallback was used, record it as `extension.md (extension) → phases K+1-K+N`.
- **Do not delete the spec.** Dated specs in `.tasks/specs/` are immutable history; the `## Specs` log marks it consumed so a later run won't reapply it. (A deprecated root `extension.md` fallback *may* be deleted after use — see "Deprecated fallbacks".)
- Commit: `chore(tasks): extend with N phase(s) — <comma-separated titles>`.
- Do not push automatically. Only push or perform GitHub operations when the user explicitly asks.
- Tell the user: "Added Phase K+1..K+N. Start a new session and invoke `$phase-execute` to begin."

## Edge Cases

- **Multiple unconsumed specs** — list them with their dates/kinds and ask the user which to consume; never auto-pick more than the single newest, and never consume more than one spec per run.
- **`kind` / mode mismatch** — a `kind: extension` spec selected in Bootstrap mode (no `project.md`), or a `kind: bootstrap` spec selected in Extend mode (`project.md` exists), is an error. Stop and report: *"Spec kind '<kind>' does not match inferred mode '<mode>'."* Do not auto-fix or re-route.
- **Mid-stream extension while a phase is open** — append after the open phase. Don't touch the open phase or its tasks. `current-phase` stays on the open phase.
- **Extension spec exists but `.tasks/project.md` doesn't** — stop and tell the user: "Found a kind: extension spec but no .tasks/ project. Did you mean a bootstrap spec?" Do not auto-rename or proceed. (Same for a deprecated root `extension.md`.)
- **Already-consumed spec named explicitly** — if the user names a spec already in the `## Specs` log, confirm before reprocessing; re-consuming would duplicate phases.
- **Project status was `done`** — flip to `in-progress`. Leave closed phases' `closed:` dates intact and untouched.
- **User wants tasks pre-filled in the new phase** — out of scope here. Tasks are deferred to `$phase-execute`. The user can edit `phase-N/phase.md` directly if they want explicit task control.

## Rules

- **One spec per run** — each orchestrate run consumes exactly one spec and logs it under `## Specs`.
- **Specs are immutable** — never edit or delete a dated spec in `.tasks/specs/`; consumption is tracked in `project.md`'s `## Specs` log, not by deleting the file.
- Keep `.tasks/` as the single source of truth.
- Never backfill fake status, dates, or GitHub metadata.
- Never generate future-phase task files during initialization.
- Prefer concrete tasks and acceptance criteria over broad placeholders.
- If the request is too vague to produce useful phases, stop and ask for the missing project goal rather than inventing it.
