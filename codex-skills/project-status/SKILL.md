---
name: project-status
description: Read-only status report for an agentflow `.tasks/` project. Use when Codex needs to answer "project status", "where are we", "what's done", "what's left", or any request for a progress overview. Reports phases, blockers, next action, and recent git activity without modifying files.
---

# Project Status

Report the current state of an agentflow project from `.tasks/` plus minimal read-only git context. Never open phases, advance tasks, edit files, or commit. If the user wants to do the next task, point them to `$phase-execute` or `$task-implement`.

## Workflow

### Step 1: Confirm project tracking

Check for `.tasks/project.md` in the current working directory.

If it is absent, report:

```text
No agentflow project found here. Run `project-orchestrate` to bootstrap one.
```

Stop there. Do not search parent directories.

### Step 2: Read project metadata

Read `.tasks/project.md`. Capture from frontmatter:
- `title`
- `status`
- `current-phase`
- `github`

From the `## Phases` section, capture each phase title and whether the checkbox is `[x]` or `[ ]`.

### Step 3: Walk phases

Glob `.tasks/phase-*/phase.md`. For each phase, read frontmatter:
- `phase`
- `title`
- `status` (`open`, `pending`, or `closed`)
- `opened`
- `closed`

Sort phases by number and tally closed, open, and pending counts.

### Step 4: Inspect the open phase

If a phase has `status: open`, glob its `task-*.md` files. For each task, read frontmatter:
- `id`
- `title`
- `status` (`pending`, `in-progress`, `done`, or `blocked`)
- `blocked-by`

Then:
- Tally task status counts.
- Collect tasks with `status: blocked`; read their `## Notes` section for the reason.
- Collect tasks whose `blocked-by` references a task that is not yet `done`.
- Determine the next action:
  - If a task is `in-progress`, resume that task.
  - Else choose the lowest-numbered `pending` task with no unmet `blocked-by`.
  - Else if all tasks are `done` or `blocked`, report that the phase is ready to close via `$phase-execute`.
  - Else if there is no open phase but pending phases remain, report that `$phase-execute` should open the next phase.
  - Else if all phases are closed, report that the project is complete.

If an open phase has no task files, report that the phase has no tasks yet and `$phase-execute` should generate them.

### Step 5: Add git context

Run only these read-only git commands:

```bash
git branch --show-current
git status --short
git log --oneline -5
```

If the directory is not a git repository, omit git activity silently.

Never run mutating git commands.

### Step 6: Render one report

Return a single markdown report. Do not write files. Use this shape, omitting sections that do not apply:

```markdown
# <project title>
Status: <in-progress|done> | Phase <current>/<total> | Branch: <branch>
<github URL if present>

## Phases
- [x] Phase 1: <title> (closed <date>)
- [>] Phase 2: <title> (open since <date>)
- [ ] Phase 3: <title> (pending)

## Phase <N> Progress
<D> done | <I> in-progress | <P> pending | <B> blocked (<total> tasks)

## Blockers
- task-05-<name>: blocked-by task-04-<name> (in-progress)
- task-07-<name>: status=blocked - "<reason from Notes>"

## Next Action
Resume `task-04-<name>` (in-progress): <title>

## Recent Activity
- <hash> <commit subject>
- <hash> <commit subject>
<"N uncommitted changes" if git status is non-empty>
```

Use `[x]` for closed phases, `[>]` for the open phase, and `[ ]` for pending phases. If there are no blockers, write `No blockers.` If the project is complete, omit Blockers and Next Action.

If `extension.md` exists at the repo root, append one line to the report: "Pending extension brief detected — invoke `$project-orchestrate` to append." Do not read or modify the file.

## Rules

- Read current file state every time; never rely on prior conversation.
- Treat `.tasks/` as the source of truth.
- Keep the whole workflow read-only: do not use `apply_patch`, shell writes, file edits, phase transitions, task status updates, commits, or pushes.
- Return one report in one response.
- Hand off execution to `$phase-execute` or `$task-implement`; do not advance work in this skill.
