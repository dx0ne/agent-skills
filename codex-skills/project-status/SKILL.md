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

### Step 5: Detect unconsumed specs

Glob `.tasks/specs/*.md`. A spec is **consumed** if its relative path (e.g. `specs/2026-06-17-auth.md`) appears anywhere in the `## Specs` log from `.tasks/project.md`. Log lines look like:

```
- specs/2026-06-17-auth.md (bootstrap) → phases 1-3
- specs/2026-07-02-billing.md (extension) → phases 4-5
```

Any spec file whose path does not appear in the log is **unconsumed**. Collect the list of unconsumed spec filenames. You do not need to read spec file bodies — filenames are sufficient for detection.

**Deprecated fallback check (secondary signal):** Also note if `brief.md` or `extension.md` exists at the repo root. These are deprecated pre-spec-folder input files. If either is present and no dated spec in `.tasks/specs/` covers the same intent, surface it as a secondary signal (see report template below).

### Step 6: Add git context

Run only these read-only git commands:

```bash
git branch --show-current
git status --short
git log --oneline -5
```

If the directory is not a git repository, omit git activity silently.

Never run mutating git commands.

### Step 7: Render one report

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

## Unconsumed Specs
- specs/2026-06-17-foo.md
- specs/2026-07-02-bar.md
→ Invoke `$project-orchestrate` to consume these specs and generate phases.

## Recent Activity
- <hash> <commit subject>
- <hash> <commit subject>
<"N uncommitted changes" if git status is non-empty>
```

Use `[x]` for closed phases, `[>]` for the open phase, and `[ ]` for pending phases. If there are no blockers, write `No blockers.` If the project is complete, omit Blockers and Next Action.

Include the **Unconsumed Specs** section only when there is at least one unconsumed spec. List each by its relative path within `.tasks/`. If deprecated root files (`brief.md` or `extension.md`) are also present, append a note: "Deprecated root file(s) also present: `brief.md` / `extension.md` — migrate to `.tasks/specs/`."

## Edge Cases

- **No `.tasks/` folder** → bootstrap hint (see Step 1).
- **No open phase, pending phases remain** → Next Action = "Invoke `$phase-execute` to open Phase N."
- **All phases closed** → "Project complete." Skip Blockers and Next Action.
- **Open phase has no task files yet** → "Phase has no tasks yet. Invoke `$phase-execute` to generate them."
- **`.tasks/specs/` has unconsumed specs** → include the Unconsumed Specs section in the report with a `$project-orchestrate` hint. This is the primary detection mechanism.
- **Deprecated root `brief.md` or `extension.md` exists** → secondary signal only; mention alongside unconsumed specs if both present, or on its own if `.tasks/specs/` is empty or absent. Do not read or modify these files.
- **`.tasks/specs/` does not exist or is empty, but `brief.md`/`extension.md` exists at root** → surface as: "Deprecated extension/bootstrap brief detected at repo root — invoke `$project-orchestrate` to consume or migrate to `.tasks/specs/`."
- **Not a git repo** → omit the Recent Activity section silently.

## Rules

- Read current file state every time; never rely on prior conversation.
- Treat `.tasks/` as the source of truth.
- Keep the whole workflow read-only: do not use `apply_patch`, shell writes, file edits, phase transitions, task status updates, commits, or pushes.
- Return one report in one response.
- Hand off execution to `$phase-execute` or `$task-implement`; do not advance work in this skill.
- **Spec detection is read-only.** Only read filenames from `.tasks/specs/` and the `## Specs` log from `project.md`. Never read spec file bodies for status detection, and never modify any spec or log.
