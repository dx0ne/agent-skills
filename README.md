# dx0ne/agent-skills

Agent skills for Claude Code and Codex.

This repo currently ships the same core workflow in two packaging styles:

- `skills/`: Claude-compatible plugin layout, registered via `.claude-plugin/marketplace.json`
- `codex-skills/`: Codex-native plugin layout, registered via `.agents/plugins/marketplace.json`

## Included Skills

### agentflow

Project execution workflow designed for multi-session agentic work. All state lives in a `.tasks/` folder tracked in git, so any later session can reconstruct project state by reading it.

```text
project-specify  ->  project-orchestrate  ->  phase-execute  ->  task-implement
```

**`project-specify`**

Turn a raw idea into a reviewed, dated spec — then hand off to `project-orchestrate`. Runs a disciplined interview (one question at a time, multiple-choice preferred), proposes 2–3 approaches with trade-offs, presents the design in sections for approval, then writes an immutable dated spec to `.tasks/specs/YYYY-MM-DD-<slug>.md`. A `<HARD-GATE>` prevents any implementation or orchestration until both the design and the written spec file are explicitly approved by the user. Terminal state is always `agentflow:project-orchestrate`, so a raw idea flows straight into the phased `.tasks/` structure.

**`project-orchestrate`**

Initialize a project-level `.tasks/` workspace from a spec in `.tasks/specs/` (selected by explicit path, or the newest unconsumed spec, or a deprecated root `brief.md`). Creates `project.md`, `phase.md` files, and Phase 1 task files, then records the consumed spec in `project.md`'s `## Specs` log. Also extends an existing `.tasks/` project from a `kind: extension` spec in `.tasks/specs/` (or a deprecated root `extension.md`).

**`phase-execute`**

Run one phase from `.tasks/`. Open the next pending phase when needed, execute or supervise pending tasks, and close the phase when its tasks are complete or blocked. To keep the long supervision loop cheap, the executor never does heavy work in its own context: task generation is pushed to a one-shot planner subagent, and exit-criteria test/build runs to a verifier subagent — each returns only a compact summary, so the executor's context (re-read from cache every turn) stays lean.

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
- The Codex skills live under `codex-skills/<plugin>/skills/` and are packaged through `.agents/plugins/marketplace.json`, one `.codex-plugin/plugin.json` per plugin (`agentflow`, `utils`).
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

Install from the plugin marketplace ([Codex plugins docs](https://developers.openai.com/codex/plugins)):

```text
codex plugin marketplace add dx0ne/agent-skills
```

Then install `agentflow` and/or `utils` from the `/plugins` directory (or `@`-reference them directly once installed). This registers this repo's `.agents/plugins/marketplace.json`, which points at the `agentflow` and `utils` plugin folders under `codex-skills/`.

#### Manual / flat-folder install

Codex also discovers plain skill folders from repository, user, admin, and system locations, independent of the plugin system. For project-specific skills, place skill folders under `.agents/skills` in the repository or a parent folder of the directory where you launch Codex. Codex scans `.agents/skills` from the current working directory up to the repository root. See the [OpenAI Codex skills docs](https://developers.openai.com/codex/skills).

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
~/.codex/skills/
  project-orchestrate/
  phase-execute/
  task-implement/
  project-status/
  yolo/
```

This repository stores Codex-native skill folders under `codex-skills/<plugin>/skills/` (`codex-skills/agentflow/skills/` and `codex-skills/utils/skills/`). Each installed Codex skill folder should contain:

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
cp -R codex-skills/agentflow/skills/project-specify .agents/skills/
cp -R codex-skills/agentflow/skills/project-orchestrate .agents/skills/
cp -R codex-skills/agentflow/skills/phase-execute .agents/skills/
cp -R codex-skills/agentflow/skills/task-implement .agents/skills/
cp -R codex-skills/agentflow/skills/project-status .agents/skills/
cp -R codex-skills/utils/skills/yolo .agents/skills/
```

**Project install, Windows PowerShell**

```powershell
New-Item -ItemType Directory -Force ".\.agents\skills" | Out-Null
Copy-Item -Recurse -Force ".\codex-skills\agentflow\skills\project-specify" ".\.agents\skills\"
Copy-Item -Recurse -Force ".\codex-skills\agentflow\skills\project-orchestrate" ".\.agents\skills\"
Copy-Item -Recurse -Force ".\codex-skills\agentflow\skills\phase-execute" ".\.agents\skills\"
Copy-Item -Recurse -Force ".\codex-skills\agentflow\skills\task-implement" ".\.agents\skills\"
Copy-Item -Recurse -Force ".\codex-skills\agentflow\skills\project-status" ".\.agents\skills\"
Copy-Item -Recurse -Force ".\codex-skills\utils\skills\yolo" ".\.agents\skills\"
```

**User install, macOS / Linux**

```bash
mkdir -p ~/.codex/skills
cp -R codex-skills/agentflow/skills/project-specify ~/.codex/skills/
cp -R codex-skills/agentflow/skills/project-orchestrate ~/.codex/skills/
cp -R codex-skills/agentflow/skills/phase-execute ~/.codex/skills/
cp -R codex-skills/agentflow/skills/task-implement ~/.codex/skills/
cp -R codex-skills/agentflow/skills/project-status ~/.codex/skills/
cp -R codex-skills/utils/skills/yolo ~/.codex/skills/
```

**User install, Windows PowerShell**

```powershell
New-Item -ItemType Directory -Force "$HOME\.codex\skills" | Out-Null
Copy-Item -Recurse -Force ".\codex-skills\agentflow\skills\project-specify" "$HOME\.codex\skills\"
Copy-Item -Recurse -Force ".\codex-skills\agentflow\skills\project-orchestrate" "$HOME\.codex\skills\"
Copy-Item -Recurse -Force ".\codex-skills\agentflow\skills\phase-execute" "$HOME\.codex\skills\"
Copy-Item -Recurse -Force ".\codex-skills\agentflow\skills\task-implement" "$HOME\.codex\skills\"
Copy-Item -Recurse -Force ".\codex-skills\agentflow\skills\project-status" "$HOME\.codex\skills\"
Copy-Item -Recurse -Force ".\codex-skills\utils\skills\yolo" "$HOME\.codex\skills\"
```

If multiple installed skills share the same `name`, Codex does not merge them. Keep repo-scoped skill names distinct from user-scoped variants unless you intentionally want both to appear in skill selectors.

## Typical Workflow

For Claude Code (full pipeline):

1. Start a new project session and invoke `project-specify` — interview → design → write spec → approve.
2. `project-specify` hands off to `project-orchestrate`, which builds the `.tasks/` structure from the approved spec.
3. Use `project-status` whenever a session needs a read-only progress brief.
4. Start a new session for each phase and invoke `phase-execute`.
5. Use `task-implement` for direct single-task execution when needed.

For Codex (same pipeline):

1. Start a new project session and invoke `project-specify` — interview → design → write spec → approve.
2. `project-specify` hands off to `project-orchestrate`, which builds the `.tasks/` structure from the approved spec.
3. Continue with `phase-execute` and `task-implement` as above; use `project-status` for a read-only progress brief.

For Codex specifically, `phase-execute` may perform tasks in the current agent instead of automatically dispatching subagents.
