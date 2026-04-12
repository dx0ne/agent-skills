# dx0ne/agent-skills

Public skill distribution repo for Claude Code and compatible agents. Conforms to the [agentskills.io spec](https://agentskills.io/specification).

## Structure

```
agent-skills/
├── .claude-plugin/
│   └── marketplace.json     ← plugin registry
├── skills/
│   ├── project-orchestrate/ ─┐
│   ├── phase-execute/        ├─ agentflow plugin
│   ├── task-implement/      ─┘
│   └── yolo/                ← utils plugin
└── README.md
```

## Plugins

| Plugin | Skills | Purpose |
|--------|--------|---------|
| `agentflow` | project-orchestrate, phase-execute, task-implement | Three-tier project execution pipeline |
| `utils` | yolo | Standalone utility skills |

## Skill Sources

- **agentflow skills** — canonical source is `D:\Projects\agentflow\plugin\skills\`. When those skills change, copy them here.
- **yolo** — canonical source is `C:\Users\greg\.claude\skills\yolo\SKILL.md`. Update here when that changes.

## Adding a Skill

1. Create `skills/<skill-name>/SKILL.md` — frontmatter `name` must exactly match the folder name
2. Add the path to the appropriate plugin in `.claude-plugin/marketplace.json`
3. If it doesn't fit an existing plugin, add a new plugin entry in the manifest
4. Update README.md

## Adding a Plugin

Add a new entry to `.claude-plugin/marketplace.json`:

```json
{
  "name": "plugin-name",
  "description": "...",
  "source": "./",
  "strict": false,
  "skills": ["./skills/skill-one", "./skills/skill-two"]
}
```

## Spec Rules (agentskills.io)

- `name` field: lowercase, hyphens only, no leading/trailing hyphens, no consecutive hyphens, max 64 chars
- `name` must match the parent directory name exactly
- `description`: max 1024 chars, describe what it does AND when to use it
- Keep `SKILL.md` body under 500 lines — move detailed reference to `references/` if needed

## Install Commands

```bash
# Claude Code
/plugin marketplace add dx0ne/agent-skills
/plugin install agentflow@dx0ne-agent-skills
/plugin install utils@dx0ne-agent-skills

# skills.sh
npx skills add dx0ne/agent-skills
```

## Validation

After changes, verify:
- Skill folder names match their `name` frontmatter field
- All paths in `marketplace.json` resolve to directories containing `SKILL.md`
- Test install in a Claude Code session with `/plugin marketplace add dx0ne/agent-skills`
