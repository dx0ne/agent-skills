# dx0ne/agent-skills

Agent skills for Claude Code and Codex.

This repo currently ships the same core workflow in two packaging styles:

- `skills/`: Claude-compatible plugin layout
- `codex-skills/`: Codex-native standalone skills

## Included Skills

### agentflow

Three-tier project execution pipeline designed for multi-session agentic work. All state lives in a `.tasks/` folder tracked in git, so any later session can reconstruct project state by reading it.

```text
project-orchestrate  ->  phase-execute  ->  task-implement
```

**`project-orchestrate`**

Initialize a project-level `.tasks/` workspace from a `brief.md` or direct project request. Create `project.md`, `phase.md` files, and Phase 1 task files.

**`phase-execute`**

Run one phase from `.tasks/`. Open the next pending phase when needed, execute or supervise pending tasks, and close the phase when its tasks are complete or blocked.

**`task-implement`**

Execute one tracked task end to end: read the task file, mark it in progress, implement the work, verify acceptance criteria, fill in notes, and return `DONE`, `DONE_WITH_CONCERNS`, or `BLOCKED`.

**Task file structure** (`.tasks/phase-N/task-NN-name.md`)

```yaml
---
id: task-01
title: Set up database schema
status: pending
complexity: medium
blocked-by: ~
---
## Goal
## Context
## Acceptance Criteria
- [ ] criterion
## Notes
```

### utils

**`yolo`**

Stage, commit, and push the current branch without extra confirmation prompts.

## Agent Differences

The Claude and Codex versions are intentionally similar, but they are not identical:

- The Claude skills live under `skills/` and are packaged through `.claude-plugin/marketplace.json`.
- The Codex skills live under `codex-skills/` as standalone skill folders.
- The Codex `phase-execute` port defaults to serial execution and only delegates to subagents when the user explicitly wants delegation or parallel agent work.
- The Codex ports remove Claude-specific model routing and Claude-specific co-author behavior.

## Install

### Claude Code

Install from the plugin marketplace:

```text
/plugin marketplace add dx0ne/agent-skills
/plugin install agentflow@dx0ne-agent-skills
/plugin install utils@dx0ne-agent-skills
```

You can also install through `skills.sh`:

```bash
npx skills add dx0ne/agent-skills
```

`skills.sh` is documented as installing the repository skill collection format. Do not assume it installs the Codex-native `codex-skills/` folders into Codex automatically.

### Codex

Copy each desired skill folder from `codex-skills/` into your Codex skills directory, usually `~/.codex/skills/`.

If you want a one-command install, use the helper scripts in this repo:

```bash
./install-codex.sh
```

```powershell
.\install-codex.ps1
```

Example:

```text
~/.codex/skills/
  project-orchestrate/
  phase-execute/
  task-implement/
  yolo/
```

Each Codex skill folder should contain:

- `SKILL.md`
- `agents/openai.yaml`

On Windows, that usually means copying these folders:

- `codex-skills/project-orchestrate`
- `codex-skills/phase-execute`
- `codex-skills/task-implement`
- `codex-skills/yolo`

Example copy commands:

**macOS / Linux**

```bash
mkdir -p ~/.codex/skills
cp -R codex-skills/project-orchestrate ~/.codex/skills/
cp -R codex-skills/phase-execute ~/.codex/skills/
cp -R codex-skills/task-implement ~/.codex/skills/
cp -R codex-skills/yolo ~/.codex/skills/
```

**Windows PowerShell**

```powershell
New-Item -ItemType Directory -Force "$HOME\.codex\skills" | Out-Null
Copy-Item -Recurse -Force ".\codex-skills\project-orchestrate" "$HOME\.codex\skills\"
Copy-Item -Recurse -Force ".\codex-skills\phase-execute" "$HOME\.codex\skills\"
Copy-Item -Recurse -Force ".\codex-skills\task-implement" "$HOME\.codex\skills\"
Copy-Item -Recurse -Force ".\codex-skills\yolo" "$HOME\.codex\skills\"
```

The current OpenAI docs describe skills as installed in Codex and then invoked inside threads or projects. They do not currently document project-specific skill installation. The safe assumption is:

- skills are installed at the Codex app or user level
- projects are folder-scoped workspaces where you use those installed skills

## Typical Workflow

For either agent:

1. Start a new project session and invoke `project-orchestrate`.
2. Start a new session for each phase and invoke `phase-execute`.
3. Use `task-implement` for direct single-task execution when needed.

For Codex specifically, `phase-execute` may perform tasks in the current agent instead of automatically dispatching subagents.
