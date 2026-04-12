# dx0ne/agent-skills

Agent skills for Claude Code and compatible agents.

## Plugins

### agentflow

Three-tier project execution pipeline designed for multi-session agentic work. All state lives in a `.tasks/` folder tracked in git — any agent in any session can reconstruct full project state by reading it.

```
project-orchestrate  →  phase-execute  →  task-implement
      (you)               (executor)         (subagent)
  sets up phases       runs one phase     implements one task
```

**Tier 1 — `project-orchestrate`**

Run once at the start of a project. Reads a `brief.md` (or interviews you), creates a GitHub repo, and scaffolds `.tasks/` with a `project.md`, per-phase `phase.md` files, and task files for Phase 1. Future phases get stubs only — tasks are generated when each phase opens, keeping them relevant.

**Tier 2 — `phase-execute`**

Run at the start of each new session to work a phase. Finds the current open phase, dispatches a subagent per task (each invoking `task-implement`), reviews results, and closes the phase when done. The executor never implements — it only supervises. Selects model by task complexity: Haiku for low, Sonnet for medium, Opus for high.

**Tier 3 — `task-implement`**

Called by subagents dispatched from `phase-execute`. Reads the task file, marks it in-progress, invokes TDD, implements, verifies acceptance criteria, fills in notes, and returns `DONE`, `DONE_WITH_CONCERNS`, or `BLOCKED` to the executor.

**Task file structure** (`.tasks/phase-N/task-NN-name.md`):
```yaml
---
id: task-01
title: Set up database schema
status: pending        # pending → in-progress → done | blocked
complexity: medium     # low | medium | high
blocked-by: ~
---
## Goal
## Context
## Acceptance Criteria
- [ ] criterion
## Notes
```

**Typical workflow:**

1. Start a new project session → invoke `project-orchestrate`
2. Start a new session for each phase → invoke `phase-execute`
3. Tasks are implemented automatically by subagents via `task-implement`

| Skill | Trigger |
|-------|---------|
| `project-orchestrate` | "start a new project", "plan this project" |
| `phase-execute` | "execute phase", "continue project", new session with `.tasks/` present |
| `task-implement` | dispatched by `phase-execute`, or "implement this task" |

### utils

| Skill | Trigger |
|-------|---------|
| `yolo` | Commit and push everything without prompts |

## Install

### Claude Code plugin marketplace

```
/plugin marketplace add dx0ne/agent-skills
/plugin install agentflow@dx0ne-agent-skills
/plugin install utils@dx0ne-agent-skills
```

### skills.sh CLI

```
npx skills add dx0ne/agent-skills
```
