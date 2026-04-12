# dx0ne/agent-skills

Agent skills for Claude Code and compatible agents.

## Plugins

### agentflow

Three-tier project execution hierarchy.

| Skill | Trigger |
|-------|---------|
| `project-orchestrate` | Break a project into phases with goals and tasks |
| `phase-execute` | Execute one phase of a plan end-to-end |
| `task-implement` | Implement a single well-defined task |

Use them as a pipeline (`orchestrate → phase → task`) or invoke each independently.

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
