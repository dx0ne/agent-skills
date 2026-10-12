---
name: project-status
description: Read-only status report for an agentflow project. Triggers on "project status", "what's the status", "where are we", "what's done", "what's left", or any request for a progress overview of a `.tasks/`-tracked project. Reports phases, blockers, next action, and recent git activity. Never modifies files.
---

# Project Status

Reports the state of an agentflow project from `.tasks/` plus minimal git context. Strictly read-only — never opens phases, never advances tasks, never commits. If the user wants to *do* the next task, hand off to `phase-execute`.

## When to Use

- The user asks "where are we", "what's the status", "what's done", "what's left", or similar.
- A new session is starting and you need to brief yourself before working.
- Another agent or human asked for a project summary.

Do NOT use to advance work — that's `phase-execute`. Do NOT use this skill to modify any file.

## Preconditions

Requires `.tasks/project.md` in the current working directory. If absent, report:

> No agentflow project found here. Run `project-orchestrate` to bootstrap one.

…and stop. Do not search parent directories.

## Process

```dot
digraph status {
    "Read .tasks/project.md" [shape=box];
    "project.md exists?" [shape=diamond];
    "Exit: bootstrap hint" [shape=doublecircle];
    "Walk phase-*/phase.md" [shape=box];
    "Open phase exists?" [shape=diamond];
    "Read open phase tasks" [shape=box];
    "Tally + find blockers + next action" [shape=box];
    "Glob .tasks/specs/ + check ## Specs log" [shape=box];
    "Read git context" [shape=box];
    "Render report" [shape=doublecircle];

    "Read .tasks/project.md" -> "project.md exists?";
    "project.md exists?" -> "Exit: bootstrap hint" [label="no"];
    "project.md exists?" -> "Walk phase-*/phase.md" [label="yes"];
    "Walk phase-*/phase.md" -> "Open phase exists?";
    "Open phase exists?" -> "Read open phase tasks" [label="yes"];
    "Open phase exists?" -> "Glob .tasks/specs/ + check ## Specs log" [label="no"];
    "Read open phase tasks" -> "Tally + find blockers + next action";
    "Tally + find blockers + next action" -> "Glob .tasks/specs/ + check ## Specs log";
    "Glob .tasks/specs/ + check ## Specs log" -> "Read git context";
    "Read git context" -> "Render report";
}
```

### Step 1 — Read project metadata

Read `.tasks/project.md`. Capture from frontmatter: `title`, `status`, `current-phase`, `github`. From the `## Phases` section, capture each phase title and whether the checkbox is `[x]` or `[ ]`. Also capture the full `## Specs` log section — you will need it in Step 4.

### Step 2 — Walk phases

Glob `.tasks/phase-*/phase.md`. For each, read frontmatter: `phase`, `title`, `status` (`open` | `pending` | `closed`), `opened`, `closed`. Sort by phase number. Tally counts: closed / open / pending.

### Step 3 — Inspect the open phase

If a phase has `status: open`, glob its `task-*.md` files. For each task, read frontmatter: `id`, `title`, `status` (`pending` | `in-progress` | `done` | `blocked`), `blocked-by`.

- Tally task status counts.
- **Collect blockers**:
  - Tasks with `status: blocked` — read the `## Notes` section for the reason.
  - Tasks whose `blocked-by` references a task that is not yet `done`.
- **Determine next action**:
  - If a task has `status: in-progress` → that's the next action (resume it).
  - Else lowest-numbered `status: pending` task with no unmet `blocked-by`.
  - Else if all tasks are `done`/`blocked` → "Phase ready to close — invoke `phase-execute`."
  - Else if no open phase but pending phases remain → "Invoke `phase-execute` to open Phase N."
  - Else if all phases closed → "Project complete."

**Carry-forward:** in the open phase's `phase.md` (or, with no open phase, the next pending one), count the numbered items under `## Carry from phase <N-1>` and the items under `## Open follow-ups from phase <N-1>`. If every phase is closed, count them under the last phase's `## Carry-forward` heading instead. Skip "none" entries.

### Step 4 — Detect unconsumed specs

Glob `.tasks/specs/*.md`. A spec is **consumed** if its relative path (e.g. `specs/2026-06-17-auth.md`) appears anywhere in the `## Specs` log you captured in Step 1. Log lines look like:

```
- specs/2026-06-17-auth.md (bootstrap) → phases 1-3
- specs/2026-07-02-billing.md (extension) → phases 4-5
```

Any spec file whose path does not appear in the log is **unconsumed**. Collect the list of unconsumed spec filenames. You do not need to read spec file bodies — filenames are sufficient for detection.

**Deprecated fallback check (secondary signal):** Also note if `brief.md` or `extension.md` exists at the repo root. These are the deprecated pre-spec-folder input files. If either is present and no dated spec in `.tasks/specs/` covers the same intent, surface it as a secondary signal (see report template below).

### Step 5 — Git context

Run only these read-only commands:

- `git branch --show-current`
- `git status --short`
- `git log --oneline -5`

Never run mutating git commands. If the directory is not a git repo, skip this step silently.

### Step 6 — Render report

Output a single markdown report to the user. Do not write any files. Use this template, omitting sections that don't apply:

```
# <project title>
Status: <in-progress|done> · Phase <current>/<total> · Branch: <branch>
<github URL if present>

## Phases
- [x] Phase 1: <title> (closed <date>)
- [>] Phase 2: <title> (open since <date>)
- [ ] Phase 3: <title> (pending)

## Phase <N> Progress
<D> done · <I> in-progress · <P> pending · <B> blocked  (<total> tasks)

## Blockers
- task-05-<name>: blocked-by task-04-<name> (in-progress)
- task-07-<name>: status=blocked — "<reason from Notes>"

## Next Action
Resume `task-04-<name>` (in-progress) — <title>

## Carry-forward
<K> carry items · <L> open follow-ups from phase <N-1> (see `.tasks/phase-<N>/phase.md`)

## Unconsumed Specs
- specs/2026-06-17-foo.md
- specs/2026-07-02-bar.md
→ Invoke `project-orchestrate` to consume these specs and generate phases.

## Recent Activity
- <hash> <commit subject>
- <hash> <commit subject>
<"N uncommitted changes" if git status non-empty>
```

Use `[x]` for closed phases, `[>]` for the open phase, `[ ]` for pending. If there are no blockers, write "No blockers." If the project is complete, omit Blockers and Next Action.

Include the **Carry-forward** section only when at least one carry item or open follow-up was counted in Step 3. Report counts and the file path only; do not copy the items into the report.

Include the **Unconsumed Specs** section only when there is at least one unconsumed spec. List each by its relative path within `.tasks/`. If deprecated root files (`brief.md` or `extension.md`) are also present, append a note: "Deprecated root file(s) also present: `brief.md` / `extension.md` — migrate to `.tasks/specs/`."

## Edge Cases

- **No `.tasks/` folder** → bootstrap hint (see Preconditions).
- **No open phase, pending phases remain** → Next Action = "Invoke `phase-execute` to open Phase N."
- **All phases closed** → "Project complete." Skip Blockers and Next Action.
- **Open phase has no task files yet** → "Phase has no tasks yet. Invoke `phase-execute` to generate them."
- **`.tasks/specs/` has unconsumed specs** → include the Unconsumed Specs section in the report with a `project-orchestrate` hint. This is the primary detection mechanism.
- **Deprecated root `brief.md` or `extension.md` exists** → secondary signal only; mention alongside unconsumed specs if both present, or on its own if `.tasks/specs/` is empty or absent. Do not read or modify these files.
- **`.tasks/specs/` does not exist or is empty, but `brief.md`/`extension.md` exists at root** → surface as: "Deprecated extension/bootstrap brief detected at repo root — invoke `project-orchestrate` to consume or migrate to `.tasks/specs/`."
- **Not a git repo** → omit the Recent Activity section silently.

## Key Rules

- **Read-only.** Never use Edit or Write. Never commit. Never run mutating git commands. Never open or close phases.
- **Source of truth is `.tasks/`.** Always read current file state — don't infer from prior conversation.
- **One report, one response.** Don't paginate. Don't ask the user follow-up questions before reporting.
- **Hand off, don't advance.** When work needs to move, point to `phase-execute` or `task-implement` — don't do it yourself.
- **Spec detection is read-only.** Only read filenames from `.tasks/specs/` and the `## Specs` log from `project.md`. Never read spec file bodies for status detection, and never modify any spec or log.
