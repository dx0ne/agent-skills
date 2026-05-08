# dx0ne/agent-skills

Public skill distribution repo for Claude Code and compatible agents. Conforms to the [agentskills.io spec](https://agentskills.io/specification).

## Structure

```
agent-skills/
├── .claude-plugin/
│   └── marketplace.json     ← Claude plugin registry
├── skills/                  ← Claude-compatible plugin layout
│   ├── agentflow/
│   │   ├── project-orchestrate/
│   │   ├── phase-execute/
│   │   ├── task-implement/
│   │   └── project-status/
│   └── utils/
│       └── yolo/
├── codex-skills/            ← Codex-native standalone skills (parallel to skills/)
│   ├── project-orchestrate/
│   ├── phase-execute/
│   ├── task-implement/
│   ├── project-status/
│   └── yolo/
├── install-codex.sh         ← Codex install helper (bash)
├── install-codex.ps1        ← Codex install helper (PowerShell)
└── README.md
```

## Plugins

| Plugin | Skills | Purpose |
|--------|--------|---------|
| `agentflow` | project-orchestrate, phase-execute, task-implement, project-status | Three-tier project execution pipeline plus read-only status |
| `utils` | yolo | Standalone utility skills |

## Codex parallel layout

The repo ships the same core workflow in two packaging styles: `skills/` for Claude (plugin manifest) and `codex-skills/` for Codex (standalone skill folders, each with `SKILL.md` + `agents/openai.yaml`). They are intentionally similar but not identical — the Codex `phase-execute` defaults to serial execution, and Codex ports drop Claude-specific model routing and co-author behavior. See README.md for Codex install commands.

## Adding a Skill

1. Create `skills/<plugin-name>/<skill-name>/SKILL.md` — frontmatter `name` must exactly match the folder name
2. Add `"./skill-name"` to the appropriate plugin's `skills` array in `.claude-plugin/marketplace.json`
3. If it doesn't fit an existing plugin, add a new plugin entry in the manifest
4. **If the skill should also run in Codex**: create `codex-skills/<skill-name>/SKILL.md` and `codex-skills/<skill-name>/agents/openai.yaml`, then add the corresponding copy lines to `install-codex.sh` and `install-codex.ps1`. Not every skill needs a Codex port — port when the workflow is agent-agnostic.
5. Update README.md

## Adding a Plugin

1. Create `skills/<plugin-name>/` directory
2. Add a new entry to `.claude-plugin/marketplace.json`:

```json
{
  "name": "plugin-name",
  "description": "...",
  "source": "./skills/plugin-name",
  "strict": false,
  "skills": ["./skill-one", "./skill-two"]
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
