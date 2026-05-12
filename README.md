# dx0ne/agent-skills

Agent skills for Claude Code and Codex.

This repo currently ships the same core workflow in two packaging styles:

- `skills/`: Claude-compatible plugin layout
- `codex-skills/`: Codex-native standalone skills

## Included Skills

### agentflow

Project execution workflow designed for multi-session agentic work. All state lives in a `.tasks/` folder tracked in git, so any later session can reconstruct project state by reading it.

```text
project-orchestrate  ->  phase-execute  ->  task-implement
```

**`project-orchestrate`**

Initialize a project-level `.tasks/` workspace from a `brief.md` or direct project request. Create `project.md`, `phase.md` files, and Phase 1 task files. Also extends an existing `.tasks/` project — drop an `extension.md` (same `phases:` shape as `brief.md`) or invoke without one for an interview.

**`phase-execute`**

Run one phase from `.tasks/`. Open the next pending phase when needed, execute or supervise pending tasks, and close the phase when its tasks are complete or blocked.

**`task-implement`**

Execute one tracked task end to end: read the task file, mark it in progress, implement the work, verify acceptance criteria, fill in notes, and return `DONE`, `DONE_WITH_CONCERNS`, or `BLOCKED`.

**`project-status`**

Read-only status report. Summarize project and phase progress, surface blockers, and suggest the next action — without modifying any files. Use mid-flight to brief yourself on a project, or to ask "where are we?"

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

Codex discovers skills from repository, user, admin, and system locations. For project-specific skills, place skill folders under `.agents/skills` in the repository or a parent folder of the directory where you launch Codex. Codex scans `.agents/skills` from the current working directory up to the repository root. See the [OpenAI Codex skills docs](https://developers.openai.com/codex/skills).

Use the repository scope when the workflow should live with a project and be shared by everyone working in that repo:

```text
your-project/
  .agents/
    skills/
      project-orchestrate/
      phase-execute/
      task-implement/
      project-status/
      yolo/
```

Use the user scope when the skills should be available across all repos for your own Codex setup:

```text
~/.agents/skills/
  project-orchestrate/
  phase-execute/
  task-implement/
  project-status/
  yolo/
```

This repository stores Codex-native skill folders in `codex-skills/`. Each installed Codex skill folder should contain:

- `SKILL.md`
- `agents/openai.yaml`

If you want a one-command install, use the helper scripts in this repo.

Install into a project repository:

```bash
./install-codex.sh --repo /path/to/your/project
```

```powershell
.\install-codex.ps1 -repo D:\path\to\your\project
```

Install into your user scope:

```bash
./install-codex.sh
```

```powershell
.\install-codex.ps1 -user
```

You can also copy selected skills manually.

**Project install, macOS / Linux**

```bash
mkdir -p .agents/skills
cp -R codex-skills/project-orchestrate .agents/skills/
cp -R codex-skills/phase-execute .agents/skills/
cp -R codex-skills/task-implement .agents/skills/
cp -R codex-skills/project-status .agents/skills/
cp -R codex-skills/yolo .agents/skills/
```

**Project install, Windows PowerShell**

```powershell
New-Item -ItemType Directory -Force ".\.agents\skills" | Out-Null
Copy-Item -Recurse -Force ".\codex-skills\project-orchestrate" ".\.agents\skills\"
Copy-Item -Recurse -Force ".\codex-skills\phase-execute" ".\.agents\skills\"
Copy-Item -Recurse -Force ".\codex-skills\task-implement" ".\.agents\skills\"
Copy-Item -Recurse -Force ".\codex-skills\project-status" ".\.agents\skills\"
Copy-Item -Recurse -Force ".\codex-skills\yolo" ".\.agents\skills\"
```

**User install, macOS / Linux**

```bash
mkdir -p ~/.agents/skills
cp -R codex-skills/project-orchestrate ~/.agents/skills/
cp -R codex-skills/phase-execute ~/.agents/skills/
cp -R codex-skills/task-implement ~/.agents/skills/
cp -R codex-skills/project-status ~/.agents/skills/
cp -R codex-skills/yolo ~/.agents/skills/
```

**User install, Windows PowerShell**

```powershell
New-Item -ItemType Directory -Force "$HOME\.agents\skills" | Out-Null
Copy-Item -Recurse -Force ".\codex-skills\project-orchestrate" "$HOME\.agents\skills\"
Copy-Item -Recurse -Force ".\codex-skills\phase-execute" "$HOME\.agents\skills\"
Copy-Item -Recurse -Force ".\codex-skills\task-implement" "$HOME\.agents\skills\"
Copy-Item -Recurse -Force ".\codex-skills\project-status" "$HOME\.agents\skills\"
Copy-Item -Recurse -Force ".\codex-skills\yolo" "$HOME\.agents\skills\"
```

If multiple installed skills share the same `name`, Codex does not merge them. Keep repo-scoped skill names distinct from user-scoped variants unless you intentionally want both to appear in skill selectors.

## Typical Workflow

For either agent:

1. Start a new project session and invoke `project-orchestrate`.
2. Use `project-status` whenever a session needs a read-only progress brief.
3. Start a new session for each phase and invoke `phase-execute`.
4. Use `task-implement` for direct single-task execution when needed.

For Codex specifically, `phase-execute` may perform tasks in the current agent instead of automatically dispatching subagents.
