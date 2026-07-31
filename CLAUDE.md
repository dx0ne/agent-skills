# dx0ne/agent-skills

Public skill distribution repo for Claude Code and compatible agents. Conforms to the [agentskills.io spec](https://agentskills.io/specification).

## Structure

```
agent-skills/
├── .claude-plugin/
│   └── marketplace.json     ← Claude plugin registry
├── .agents/
│   └── plugins/
│       └── marketplace.json ← Codex plugin registry
├── skills/                  ← Claude-compatible plugin layout
│   ├── agentflow/
│   │   ├── project-specify/
│   │   ├── project-orchestrate/
│   │   ├── phase-execute/
│   │   ├── task-implement/
│   │   └── project-status/
│   └── utils/
│       └── yolo/
├── codex-skills/            ← Codex-native plugin layout (parallel to skills/)
│   ├── agentflow/
│   │   ├── .codex-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   │       ├── project-specify/
│   │       ├── project-orchestrate/
│   │       ├── phase-execute/
│   │       ├── task-implement/
│   │       └── project-status/
│   └── utils/
│       ├── .codex-plugin/
│       │   └── plugin.json
│       └── skills/
│           └── yolo/
├── install-codex.sh         ← Codex install helper (bash, flat .agents/skills fallback)
├── install-codex.ps1        ← Codex install helper (PowerShell, flat .agents/skills fallback)
└── README.md
```

## Plugins

| Plugin | Skills | Purpose |
|--------|--------|---------|
| `agentflow` | project-specify, project-orchestrate, phase-execute, task-implement, project-status | Four-tier project execution pipeline: design → plan → execute → implement; plus read-only status |
| `utils` | yolo | Standalone utility skills |

### `.tasks/specs/` dated-spec contract

`project-specify` writes specs to `.tasks/specs/YYYY-MM-DD-<slug>.md`. Key rules:
- **Specs are immutable history** — never edited or deleted after consumption.
- **Selection:** explicit path wins; otherwise `project-orchestrate` consumes the newest unconsumed spec. If several unconsumed specs exist, it lists them and asks.
- **Consumption tracking** lives in `project.md`'s `## Specs` log, not in the spec files themselves. After building phases from a spec, `project-orchestrate` appends an entry like `- specs/2026-06-17-auth-system.md (bootstrap) → phases 1-3`.
- **Mode is inferred from state:** no `.tasks/project.md` → Bootstrap (`kind: bootstrap`); `project.md` present → Extend (`kind: extension`).
- **`brief.md` / `extension.md`** in the repo root still work as deprecated fallbacks if `.tasks/specs/` has no usable spec, but new work should use the dated-spec folder.

## Codex parallel layout

The repo ships the same core workflow in two packaging styles: `skills/` for Claude (`.claude-plugin/marketplace.json`) and `codex-skills/` for Codex (`.agents/plugins/marketplace.json`). Each Codex plugin folder (`codex-skills/agentflow/`, `codex-skills/utils/`) has a `.codex-plugin/plugin.json` manifest plus a `skills/` dir of `SKILL.md` + `agents/openai.yaml` folders — mirroring the `skills/agentflow/`, `skills/utils/` grouping on the Claude side. They are intentionally similar but not identical — the Codex `phase-execute` defaults to serial execution, and Codex ports drop Claude-specific model routing and co-author behavior. `install-codex.sh`/`.ps1` remain as a flat-copy fallback into `.agents/skills` for setups that don't use the Codex plugin/marketplace system. See README.md for Codex install commands.

## Adding a Skill

1. Create `skills/<plugin-name>/<skill-name>/SKILL.md` — frontmatter `name` must exactly match the folder name
2. Add `"./skill-name"` to the appropriate plugin's `skills` array in `.claude-plugin/marketplace.json`
3. If it doesn't fit an existing plugin, add a new plugin entry in the manifest
4. **If the skill should also run in Codex**: create `codex-skills/<plugin-name>/skills/<skill-name>/SKILL.md` and `codex-skills/<plugin-name>/skills/<skill-name>/agents/openai.yaml`, then add the corresponding copy lines to `install-codex.sh` and `install-codex.ps1`. Not every skill needs a Codex port — port when the workflow is agent-agnostic.
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

3. **If the plugin should also run in Codex**: create `codex-skills/<plugin-name>/.codex-plugin/plugin.json` (`name`, `version`, `description`, `"skills": "./skills/"`) plus a `codex-skills/<plugin-name>/skills/` dir, then add an entry to `.agents/plugins/marketplace.json`:

```json
{
  "name": "plugin-name",
  "source": { "source": "local", "path": "./codex-skills/plugin-name" },
  "policy": { "installation": "AVAILABLE", "authentication": "ON_INSTALL" },
  "category": "Productivity"
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

# Codex
codex plugin marketplace add dx0ne/agent-skills
```

## Codex cachebuster (before every push that touches `codex-skills/`)

Codex caches installed plugins by version. Any change under `codex-skills/<plugin>/`
must be accompanied by a version bump in that plugin's `.codex-plugin/plugin.json`,
or Codex will keep serving the stale cached copy. Run before committing:

```powershell
python "$env:USERPROFILE\.codex\skills\.system\plugin-creator\scripts\update_plugin_cachebuster.py" ".\codex-skills\agentflow"
```

It rewrites `version` to `<base>+codex.<UTC timestamp>` (e.g. `1.0.0+codex.20260731161042`),
replacing any existing `+codex.*` suffix. Pass the matching plugin path for `utils`.
Never edit files under `~/.codex/plugins/cache` — they are overwritten on refresh.

## Validation

After changes, verify:
- Skill folder names match their `name` frontmatter field
- All paths in `.claude-plugin/marketplace.json` resolve to directories containing `SKILL.md`
- All `source.path` entries in `.agents/plugins/marketplace.json` resolve to plugin folders containing `.codex-plugin/plugin.json`, and each `plugin.json`'s `skills` path resolves to a dir of `SKILL.md` folders
- Test install in a Claude Code session with `/plugin marketplace add dx0ne/agent-skills`
- Test install in a Codex session with `codex plugin marketplace add dx0ne/agent-skills`
